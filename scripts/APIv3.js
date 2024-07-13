#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

let all = {};
let tfa = {};
let regions = {};

// Read all JSON files from the 'entries' directory
fs.readdirSync("entries").forEach((dir) => {
  fs.readdirSync(path.join("entries", dir)).forEach((file) => {
    if (file.endsWith(".json")) {
      let data = JSON.parse(
        fs.readFileSync(path.join("entries", dir, file), "utf8"),
      );
      let key = Object.keys(data)[0];
      all[key] = data[key];
    }
  });
});

// Process all entries
Object.keys(all)
  .sort()
  .forEach((entryName) => {
    let entry = all[entryName];

    // Process tfa methods
    if ("tfa" in entry) {
      entry["tfa"].forEach((method) => {
        if (!tfa[method]) tfa[method] = {};

        tfa[method][key] = entry;
      });
    }

    // Process regions
    if ("regions" in entry) {
      entry["regions"].forEach((region) => {
        if (region[0] !== "-") {
          if (!regions[region]) regions[region] = { count: 0 };

          regions[region]["count"] += 1;
        }
      });
    }

    // Rename 'categories' to 'keywords'
    if ("categories" in entry) {
      entry["keywords"] = entry["categories"];
      delete entry["categories"];
    }
  });

// Write the all.json and tfa files
const outputDir = "api/v3";
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

const writeJsonFile = (filename, data) =>
  fs.writeFileSync(
    path.join(outputDir, filename),
    JSON.stringify(data, null, 2),
  );

writeJsonFile("all.json", { all });

Object.keys(tfa).forEach((method) =>
  writeJsonFile(`${method}.json`, tfa[method]),
);

// Add the 'int' region
regions["int"] = { count: Object.keys(all).length, selection: true };

// Write regions.json
const sortedRegions = Object.entries(regions)
  .sort(([, a], [, b]) => b.count - a.count)
  .reduce((acc, [k, v]) => {
    acc[k] = v;
    return acc;
  }, {});
writeJsonFile("regions.json", sortedRegions);

// Write tfa.json
const tfaEntries = Object.entries(all)
  .filter(([, entry]) => entry.tfa)
  .sort(([a], [b]) => a.toLowerCase().localeCompare(b.toLowerCase()))
  .reduce((acc, [k, v]) => {
    acc[k] = v;
    return acc;
  }, {});
writeJsonFile("tfa.json", tfaEntries);
