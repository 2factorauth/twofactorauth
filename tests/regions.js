const fs = require("fs").promises;
const core = require("@actions/core");

const url = new URL(
  "https://raw.githubusercontent.com/stefangabos/world_countries/master/data/countries/en/world.json"
);

async function main() {
  let errors = false;
  const files = process.argv.slice(2);
  const res = await fetch(url, {
    accept: "application/json",
    "user-agent": "2factorauth/twofactorauth +https://2fa.directory/bots",
  });

  if (!res.ok) throw new Error("Unable to fetch region codes");

  const data = await res.json();
  const codes = Object.values(data).map((region) => region.alpha2);

  if (files) {
    for (const file of files) {
      const data = await fs.readFile(file, "utf8");
      const json = await JSON.parse(data);
      const entry = json[Object.keys(json)[0]];
      const { regions } = entry;

      for (const region of regions || []) {
        if (!codes.includes(region.replace("-", ""))) {
          core.error(`${region} is not a valid region code`, { file });
          errors = true;
        }
      }
    }
  }
  process.exit(+errors);
}

module.exports = main();
