const fs = require("fs").promises;
const core = require("@actions/core");

const url = new URL(
  "https://pkgstore.datahub.io/core/language-codes/language-codes_json/data/97607046542b532c395cf83df5185246/language-codes_json.json",
);

async function main() {
  let errors = false;
  const files = process.argv.slice(2);
  const res = await fetch(url, {
    accept: "application/json",
    "user-agent": "2factorauth/twofactorauth +https://2fa.directory/bots",
  });

  if (!res.ok) throw new Error("Unable to fetch language codes");

  const data = await res.json();
  const codes = Object.values(data).map((language) => language.alpha2);

  if (files) {
    for (const file of files) {
      const data = await fs.readFile(file, "utf8");
      const json = await JSON.parse(data);
      const entry = json[Object.keys(json)[0]];
      const language = entry.contact?.language;

      if (language && !codes.includes(language)) {
        core.error(`${language} is not a valid language`, { file });
        errors = true;
      }
    }
  }
  process.exit(+errors);
}

module.exports = main();
