const fs = require("fs").promises;
const core = require("@actions/core");
const Ajv = require("ajv");
const addFormats = require("ajv-formats");
const { basename } = require("node:path");

const ajv = new Ajv({ strict: false, allErrors: true });
addFormats(ajv);
require("ajv-errors")(ajv);

let errors = false;

/**
 * Logs an error message and sets the errors flag to true.
 *
 * @param {string} message - The error message to log.
 * @param {object} properties - Additional properties to log with the error.
 */
function error(message, properties) {
  core.error(message, properties);
  errors = true;
}

async function main() {
  const files = process.argv.slice(2);
  const schemaFile = await fs.readFile("tests/schemas/entries.json", "utf8");
  const schema = JSON.parse(schemaFile);
  const validate = ajv.compile(schema);

  await Promise.all(
    files.map(async (file) => {
      try {
        const json = await JSON.parse(await fs.readFile(file, "utf8"));
        const entry = json[Object.keys(json)[0]];
        validateJSONSchema(file, json, validate);
        validateFileContents(file, entry);
      } catch (e) {
        error(`Failed to process ${file}: ${e.message}`, { file });
      }
    })
  );

  process.exit(+errors);
}

/**
 * Validates the JSON schema of the provided file.
 *
 * @param {string} file - File path to be validated.
 * @param {object} json - Parsed JSON content of the file.
 * @param validate - AJV object
 */
function validateJSONSchema(file, json, validate) {
  const valid = validate(json);
  if (!valid) {
    errors = true;
    validate.errors.forEach((err) => {
      const { message, instancePath, keyword: title } = err;
      const instance = instancePath?.split("/");
      if (message)
        error(`${instance[instance.length - 1]} ${message}`, { file, title });
      else error(err, { file });
    });
  }
}

/**
 * Validates the contents of the provided file according to custom rules.
 *
 * @param {string} file - File path to be validated.
 * @param {object} entry - The main entry object within the JSON content.
 */
function validateFileContents(file, entry) {
  const valid_name = `${entry.domain}.json`;

  if (basename(file) !== valid_name)
    error(`File name should be ${valid_name}`, { file, title: "File name" });

  if (entry.url === `https://${entry.domain}`)
    error(`Unnecessary url element defined.`, { file });

  if (entry["img"] === `${entry.domain}.svg`)
    error(`Unnecessary img element defined.`, { file });

  if (file !== `entries/${entry.domain[0]}/${valid_name}`)
    error(`Entry should be placed in entries/${entry.domain[0]}/`, { file });

  if (entry.tfa?.includes("custom-software") && !entry["custom-software"])
    error("Missing custom-software element", { file });

  if (entry.tfa?.includes("custom-hardware") && !entry["custom-hardware"])
    error("Missing custom-hardware element", { file });

  if (entry.tfa && !entry.documentation)
    core.warning(
      "No documentation set. Please provide screenshots in the pull request",
      { file, title: "Missing documentation" }
    );
}

module.exports = main();
