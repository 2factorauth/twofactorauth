const fs = require("fs").promises;
const core = require("@actions/core");

async function main() {
  let errors = false;
  const files = process.argv.slice(2);
  const categoriesFile = await fs.readFile("tests/categories.json", "utf8");
  const data = JSON.parse(categoriesFile);
  const allowed_categories = Object.keys(data);

  if (files) {
    for (const file of files) {
      const data = await fs.readFile(file, "utf8");
      const json = await JSON.parse(data);
      const entry = json[Object.keys(json)[0]];
      const { categories } = entry;

      for (const category of categories || []) {
        if (!allowed_categories.includes(category)) {
          core.error(`${category} is not a valid category.`, { file });
          errors = true;
        }
      }
    }
  }
  process.exit(+errors);
}

module.exports = main();
