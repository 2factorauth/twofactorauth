#!/usr/bin/env node

const fs = require("fs").promises;
const path = require("path");
const { globSync } = require("glob");
const core = require("@actions/core");
const Ajv = require("ajv");
const addFormats = require("ajv-formats");

// Define the path to the entries and the API output directory
const entriesGlob = "entries/*/*.json";
const apiDirectory = "api/v4";
const jsonSchema = "tests/schemas/APIv4.json";

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
      const entry = data[Object.keys(data)[0]];

      // Add the main domain entry
      entries[entry.domain] = entry;

      // Duplicate entry for each additional domain
      entry["additional-domains"]?.forEach((additionalDomain) => {
        entries[additionalDomain] = entry;
      });
    })
  );

  return entries;
};

/**
 * Generate the API files from the processed entries.
 *
 * @param {Object} entries - The processed entries.
 * @returns {Promise<void>}
 */
const generateApi = async (entries) => {
  const tfaMethods = {};
  const allEntries = {};

  await Promise.all([
    ensureDir(apiDirectory),
    Object.entries(entries).map(async ([domain, entry]) => {
      const apiEntry = {
        methods: entry["tfa"],
        "custom-software": entry["custom-software"],
        "custom-hardware": entry["custom-hardware"],
        documentation: entry.documentation,
        recovery: entry.recovery,
        notes: entry.notes,
      };

      // Add to all entries
      allEntries[domain] = apiEntry;

      // Group entries by TFA/2FA methods
      entry["tfa"]?.forEach((method) => {
        tfaMethods[method] ||= {};
        tfaMethods[method][domain] = apiEntry;
      });
    }),
  ]);

  // Write all entries to all.json and each TFA/2FA method to its own JSON file in parallel
  await Promise.all([
    writeJSONFile(path.join(apiDirectory, "all.json"), allEntries),
    ...Object.entries(tfaMethods).map(([method, methodEntries]) =>
      writeJSONFile(path.join(apiDirectory, `${method}.json`), methodEntries)
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
  const schema = await readJSONFile(jsonSchema);
  const validate = ajv.compile(schema);
  const files = globSync(`${apiDirectory}/*.json`);

  // Validate each file against the schema
  await Promise.all(
    files.map(async (file) => {
      validate(await readJSONFile(file));

      validate.errors?.forEach((err) => {
        const { message, instancePath, keyword: title } = err;
        const errorPath = instancePath?.split("/").slice(1).join("/");

        core.error(`${errorPath} ${message}`, { file, title });
      });
    })
  );
};

/**
 * Main function to orchestrate the loading, processing, and API generation.
 *
 * @returns {Promise<void>}
 */
const main = async () => {
  try {
    core.info("Generating API v4");

    // Get all JSON entry files
    const files = globSync(entriesGlob);
    // Process entries and generate the API
    const entries = await processEntries(files);
    await generateApi(entries);
    await validateSchema();

    core.info("API v4 generation completed successfully");
  } catch (error) {
    core.setFailed(error);
  }
};

module.exports = main();
