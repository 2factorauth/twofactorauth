#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const algoliasearch = require("algoliasearch");
const core = require("@actions/core");
require("dotenv").config(); // Load environment variables from .env file

// Initialize Algolia client and index using environment variables
const client = algoliasearch(
  process.env.ALGOLIA_APP_ID,
  process.env.ALGOLIA_API_KEY
);
const index = client.initIndex(process.env.ALGOLIA_INDEX_NAME);

// Function to process each file
async function processFile(entry) {
  if (fs.existsSync(entry)) {
    // If the file exists, read and parse the JSON content
    const fileContent = JSON.parse(fs.readFileSync(entry, "utf8"));
    const [name, data] = Object.entries(fileContent)[0];
    core.info(`Updating ${name}`);

    // Add name and objectID to the data
    data.name = name;
    data.objectID = data.domain;

    // Rename keys if necessary
    const { tfa, categories, ...rest } = data;
    const renamedData = {
      ...rest,
      ...(tfa && { "2fa": tfa }),
      ...(categories && { category: categories }),
    };

    return renamedData;
  } else {
    // If the file does not exist, remove the corresponding object from Algolia
    const domain = path.basename(entry, ".json");
    core.info(`Removing ${domain}`);
    await index.deleteObject(domain);
    return null;
  }
}

// Main function to process files and update the Algolia index
async function main() {
  const files = process.argv.slice(2); // Get the list of files from command-line arguments
  const updates = [];
  let errors = false;

  // Process each file in parallel
  const results = await Promise.allSettled(
    files.map(async (entry) => processFile(entry))
  );

  results.forEach((result) => {
    if (result.status === "fulfilled" && result.value) {
      updates.push(result.value);
    } else if (result.status === "rejected") {
      errors = true;
      core.error(`Failed to process a file: ${result.reason}`);
    }
  });

  // If there are updates, save them to the Algolia index
  if (updates.length > 0) {
    try {
      await index.saveObjects(updates);
      core.info("All updates saved");
    } catch (err) {
      core.error("Error saving updates:", err);
      errors = true;
    }
  }
  process.exit(+errors);
}

main().catch((err) => {
  core.error(err);
  process.exit(1);
});
