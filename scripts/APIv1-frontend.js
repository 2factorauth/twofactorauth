#!/usr/bin/env node

const fs = require("fs").promises;
const path = require("path");
const { globSync } = require("glob");
const core = require("@actions/core");

const version = "v1-frontend";

// Define the path to the entries and the API output directory
const entriesGlob = "entries/*/*.json";
const apiDirectory = "api/frontend/v1";

// URL to fetch categories data from
const categoriesFile = "tests/categories.json";
const regionsUrl =
  "https://raw.githubusercontent.com/stefangabos/world_countries/master/data/countries/en/world.json";

/**
 * Read and parse a JSON file asynchronously.
 *
 * @param {string} filePath - The path to the JSON file.
 * @returns {Promise<Object>} - The parsed JSON object.
 */
const readJSONFile = (filePath) =>
  fs.readFile(filePath, "utf8").then(JSON.parse);

/**
 * Write a JSON object to a file asynchronously, ensuring the directory exists.
 *
 * @param {string} filePath - The path to the output file.
 * @param {Object} data - The JSON object to write.
 * @returns {Promise<void>}
 */
const writeJSONFile = async (filePath, data) => {
  const dir = path.dirname(filePath);
  await fs.mkdir(dir, { recursive: true });
  await fs.writeFile(
    filePath,
    JSON.stringify(data, null, process.env.NODE_ENV !== "production" ? 2 : 0)
  );
};

/**
 * Fetch and parse JSON data from a URL.
 *
 * @param {string} url - The URL to fetch data from.
 * @returns {Promise<Object>} - The parsed JSON object.
 */
const fetchJSONFromUrl = async (url) => {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to fetch JSON from ${url}: ${response.statusText}`);
  }
  return response.json();
};

/**
 * Process entries by loading and transforming them.
 *
 * @param {string[]} files - Array of file paths to process.
 * @returns {Promise<Object>} - An object containing all processed entries.
 */
const processEntries = async (files) => {
  const entries = {};

  await Promise.all(
    files.map(async (file) => {
      const data = await readJSONFile(file);
      const [mainDomain, entry] = Object.entries(data)[0];

      // Add the main domain entry
      entries[mainDomain] = entry;
    })
  );

  return entries;
};

/**
 * Generate the API files from the processed entries.
 *
 * @param {Object} entries - The processed entries.
 * @param {Object} categoriesData - The categories data fetched from the URL.
 * @param {Object} regionsData - The regions data fetched from the URL.
 * @returns {Promise<void>}
 */
const generateApi = async (entries, categoriesData, regionsData) => {
  const categoriesByRegion = {};
  const entryCountsByRegion = {};
  const categoriesUsedByRegion = {};

  // Initialize 'int' (international) region
  categoriesByRegion.int = {};
  categoriesUsedByRegion.int = new Set();

  // Collect all regions from entries that have regions arrays
  const allRegions = new Set();
  for (const entry of Object.values(entries)) {
    if (entry.regions) {
      for (const region of entry.regions) {
        const regionName = region.replace("-", "");
        allRegions.add(regionName);
      }
    }
  }

  // Process each entry
  await Promise.all(
    Object.entries(entries).map(([domain, entry]) =>
      processEntry(domain, entry)
    )
  );

  // Write region file
  await writeRegions();

  // Write 'int' region files
  await writeRegionFiles("int");

  // Write other regions
  for (const region of Object.keys(categoriesByRegion)) {
    if (region !== "int") {
      await writeRegionFiles(region);
    }
  }

  /**
   * Process a single entry and add it to the appropriate regions.
   *
   * @param {string} domain - The domain of the entry.
   * @param {Object} entry - The entry data.
   */
  async function processEntry(domain, entry) {
    const apiEntry = {
      methods: entry.tfa,
      domain: entry.domain,
      "custom-software": entry["custom-software"],
      "custom-hardware": entry["custom-hardware"],
      contact: entry.contact,
      notes: entry.notes,
      img: entry.img,
      documentation: entry.documentation,
      recovery: entry.recovery,
    };

    // Always include in 'int' region
    addEntryToRegion("int", entry.categories, domain, apiEntry);

    // Determine which regions the entry should be included in
    const { includeRegions, explicitlyIncludedRegions } =
      getIncludeRegions(entry);

    // For each region, add the entry to the region's categories
    for (const region of includeRegions) {
      if (region === "int") continue; // already processed
      addEntryToRegion(region, entry.categories, domain, apiEntry);

      // If the entry explicitly includes the region, increment the entry count
      if (explicitlyIncludedRegions.has(region)) {
        incrementEntryCount(region);
      }
    }
  }

  /**
   * Determine which regions an entry should be included in.
   *
   * @param {Object} entry - The entry data.
   * @returns {Object} - An object containing includeRegions and explicitlyIncludedRegions sets.
   */
  function getIncludeRegions(entry) {
    const includeRegions = new Set(allRegions);
    const excludeRegions = new Set();
    const explicitlyIncludedRegions = new Set();
    let hasExplicitInclude = false;

    includeRegions.delete("int"); // Exclude 'int' from processing here

    if (entry.regions && entry.regions.length > 0) {
      for (const region of entry.regions) {
        const regionName = region.replace("-", "");
        if (region.startsWith("-")) {
          excludeRegions.add(regionName);
        } else {
          explicitlyIncludedRegions.add(regionName);
          hasExplicitInclude = true;
        }
      }

      if (hasExplicitInclude) {
        // If there are explicit includes, set includeRegions to only those
        includeRegions.clear();
        for (const region of explicitlyIncludedRegions) {
          includeRegions.add(region);
        }
      }

      // Exclude regions from includeRegions
      for (const region of excludeRegions) {
        includeRegions.delete(region);
      }
    }

    return {
      includeRegions,
      explicitlyIncludedRegions,
    };
  }

  /**
   * Add an entry to the specified region and categories.
   *
   * @param {string} region - The region to add the entry to.
   * @param {string[]} categories - The categories of the entry.
   * @param {string} domain - The domain of the entry.
   * @param {Object} apiEntry - The entry data to add.
   */
  function addEntryToRegion(region, categories, domain, apiEntry) {
    if (!categoriesByRegion[region]) {
      categoriesByRegion[region] = {};
      categoriesUsedByRegion[region] = new Set();
      entryCountsByRegion[region] = 0;
    }

    categories?.forEach((category) => {
      categoriesByRegion[region][category] =
        categoriesByRegion[region][category] || {};
      categoriesByRegion[region][category][domain] = apiEntry;
      categoriesUsedByRegion[region].add(category);
    });
  }

  /**
   * Increment the entry count for a region.
   *
   * @param {string} region - The region to increment the count for.
   */
  function incrementEntryCount(region) {
    if (!entryCountsByRegion[region]) {
      entryCountsByRegion[region] = 0;
    }
    entryCountsByRegion[region] += 1;
  }

  /**
   * Write category files for a region if it meets the entry count threshold.
   *
   * @param {string} region - The region to write files for.
   */
  async function writeRegionFiles(region) {
    const entryCount = entryCountsByRegion[region] || 0;

    if (region !== "int" && entryCount < 10) {
      core.info(
        `Ignoring '${region}' as it only has ${entryCount} entr${entryCount === 1 ? "y" : "ies"}.`
      );
      return;
    }

    const regionDir = path.join(apiDirectory, region);

    // Write category files
    const categoryWrites = Object.entries(categoriesByRegion[region])
      .sort().map(([category, entries]) => {
        const sortedEntries = Object.fromEntries(
          Object.keys(entries).sort((a, b) => a.localeCompare(b)).map(entry => [entry, entries[entry]]),
        );
        writeJSONFile(path.join(regionDir, `${category}.json`), sortedEntries);
      },
    );

    // Write categories.json file
    const categoriesUsed = categoriesUsedByRegion[region];
    const categoriesDataForRegion = Object.fromEntries([
      ...[...categoriesUsed]
        .filter((category) => categoriesData[category] && category !== "other")
        .sort()
        .map((category) => [category, categoriesData[category]]),
      ["other", categoriesData["other"]],
    ]);

    const categoriesWrite = writeJSONFile(
      path.join(regionDir, "categories.json"),
      categoriesDataForRegion
    );

    await Promise.all([...categoryWrites, categoriesWrite]);
  }

  async function writeRegions() {
    const usedRegions = Object.keys(entryCountsByRegion).filter(
      (region) => entryCountsByRegion[region] > 10
    );
    const regions = regionsData.filter(({ alpha2 }) =>
      usedRegions.includes(alpha2)
    );

    const squareFlagRegions = ["ch", "np", "va"];
    const shortNames = {
      us: "United States",
      gb: "United Kingdom",
      tw: "Taiwan",
      ru: "Russia",
      kr: "South Korea",
    };

    const regionsWrite = {};

    regions.forEach(
      (region) =>
        (regionsWrite[region.alpha2] = {
          name:
            region.alpha2 in shortNames
              ? shortNames[region.alpha2]
              : region.name,
          squareFlag: squareFlagRegions.includes(region.alpha2),
        })
    );
    writeJSONFile(path.join(apiDirectory, "regions.json"), regionsWrite);
  }
};

/**
 * Main function to orchestrate the loading, processing, and API generation.
 */
(async () => {
  try {
    core.info(`Generating API ${version}`);

    // Fetch categories data from file
    const categoriesData = await readJSONFile(categoriesFile);

    // Fetch region data from URL
    const regionsData = await fetchJSONFromUrl(regionsUrl);

    // Get all JSON entry files
    const files = globSync(entriesGlob);

    // Process entries and generate the API
    const entries = await processEntries(files);
    await generateApi(entries, categoriesData, regionsData);

    core.info(`API ${version} generation completed successfully`);
  } catch (error) {
    core.setFailed(error.message);
  }
})();
