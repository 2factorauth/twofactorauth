#!/usr/bin/env node

const fs = require("fs").promises;
const path = require("path");
const Ajv = require("ajv");
const addFormats = require("ajv-formats");
const { globSync } = require("glob");
const { setFailed } = require("@actions/core");
const core = require("@actions/core");

const entriesDir = "entries";
const apiDirectory = "api/v3";
const jsonSchemaPath = "tests/schemas/APIv3.json";

/**
 * Read and parse a JSON file asynchronously.
 *
 * @param {string} filePath - The path to the JSON file.
 * @returns {Promise<Object>} - The parsed JSON object.
 */
const readJSONFile = (filePath) =>
  fs.readFile(filePath, "utf8").then(JSON.parse);

/**
 * Write a JSON object to a file asynchronously.
 *
 * @param {string} filePath - The path to the output file.
 * @param {Object} data - The JSON object to write.
 * @returns {Promise<void>}
 */
const writeJSONFile = (filePath, data) =>
  fs.writeFile(
    filePath,
    JSON.stringify(data, null, process.env.NODE_ENV !== "production" ? 2 : 0)
  );

/**
 * Ensure a directory exists, creating it if necessary.
 *
 * @param {string} dirPath - The path to the directory.
 * @returns {Promise<void>}
 */
const ensureDir = (dirPath) =>
  fs.mkdir(dirPath, { recursive: true }).catch((error) => {
    if (error.code !== "EEXIST") throw error;
  });

/**
 * Process all entries by reading JSON files from the "entries" directory,
 * sorting them, and processing each entry.
 *
 * @returns {Promise<Object>} - An object containing processed all, tfa, and regions data.
 */
const processEntries = async () => {
  let allEntries = [];
  let tfaMethods = {};
  let regions = {};

  // Read all JSON files from the "entries" directory
  const entryDirs = await fs.readdir(entriesDir);
  const filePromises = entryDirs.map(async (dir) => {
    const files = await fs.readdir(path.join(entriesDir, dir));
    return files
      .filter((file) => file.endsWith(".json"))
      .map((file) => path.join(entriesDir, dir, file));
  });
  const allFiles = (await Promise.all(filePromises)).flat();

  const all = await Promise.all(
    allFiles.map(async (file) => {
      const data = await readJSONFile(file);
      const key = Object.keys(data)[0];
      return [key, data[key]];
    })
  );

  await Promise.all(
    all
      .sort((a, b) => a[0].localeCompare(b[0]))
      .map(async ([entryName, entry]) => {
        await processEntry(entry, entryName, tfaMethods, regions);
        allEntries.push([entryName, entry]);
      })
  );

  regions = Object.entries(regions)
    .sort(([, a], [, b]) => b.count - a.count)
    .reduce((acc, [k, v]) => ((acc[k] = v), acc), {});

  const tfa = Object.entries(tfaMethods).reduce((acc, [method, entries]) => {
    acc[method] = entries.sort(([a], [b]) =>
      a.toLowerCase().localeCompare(b.toLowerCase())
    );
    return acc;
  }, {});

  return { allEntries, tfa, regions };
};

/**
 * Process a single entry, updating the tfa and regions objects.
 *
 * @param {Object} entry - The entry data.
 * @param {string} entryName - The name of the entry.
 * @param {Object} tfaMethods - The tfaMethods object to update.
 * @param {Object} regions - The regions object to update.
 */
const processEntry = (entry, entryName, tfaMethods, regions) => {
  entry["tfa"]?.forEach((method) => {
    tfaMethods[method] ||= [];
    tfaMethods[method].push([entryName, entry]);
  });

  entry["regions"]?.forEach((region) => {
    if (region[0] !== "-")
      regions[region]
        ? regions[region].count++
        : (regions[region] = { count: 0 });
  });

  entry.keywords = entry.categories;
  delete entry.categories;
};

/**
 * Generate JSON files from processed entries
 *
 * @param {Array} allEntries - The processed all entries.
 * @param {Object} tfa - The processed tfa data.
 * @param {Object} regions - The processed region data.
 * @returns {Promise<void>}
 */
const generateAPI = async (allEntries, tfa, regions) => {
  regions.int = { count: allEntries.length, selection: true };

  const tfaEntries = allEntries.filter(([, entry]) => entry["tfa"]);

  await Promise.all([
    writeJSONFile(path.join(apiDirectory, "all.json"), allEntries),
    writeJSONFile(path.join(apiDirectory, "regions.json"), regions),
    writeJSONFile(path.join(apiDirectory, "tfa.json"), tfaEntries),
    ...Object.keys(tfa).map((method) =>
      writeJSONFile(path.join(apiDirectory, `${method}.json`), tfa[method])
    ),
  ]);
};

/**
 * Validate API files against JSON schema.
 *
 * @returns {Promise<void>}
 */
const validateSchema = async () => {
  const ajv = new Ajv({ strict: false, allErrors: true });
  addFormats(ajv);
  require("ajv-errors")(ajv);

  const schema = await readJSONFile(jsonSchemaPath);
  const validate = ajv.compile(schema);
  const files = globSync(`${apiDirectory}/*.json`, {
    ignore: `${apiDirectory}/regions.json`,
  });

  await Promise.all(
    files.map(async (file) => {
      const data = await readJSONFile(file);
      validate(data);
      validate.errors?.forEach((err) => {
        const { message } = err;
        throw new Error(`${file} - ${message}`);
      });
    })
  );
};

/**
 * Main function to process entries, ensure directories, serialize results, and validate schema.
 *
 * @returns {Promise<void>}
 */
const main = async () => {
  try {
    core.info("Generating API v3");
    const { allEntries, tfa, regions } = await processEntries();
    await ensureDir(apiDirectory);
    await generateAPI(allEntries, tfa, regions);
    await validateSchema();
    core.info("API v3 generation completed successfully");
  } catch (e) {
    setFailed(e);
  }
};

module.exports = main();
