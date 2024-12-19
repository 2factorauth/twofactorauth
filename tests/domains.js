const fs = require("fs").promises;
const core = require("@actions/core");

async function main(files) {
  await Promise.all(
    files.map(async (file) => {
      const json = JSON.parse(await fs.readFile(file));
      const entry = json[Object.keys(json)[0]];

      if (entry.domain.startsWith("www."))
        core.warning("Domains should not start with `www.`", { file });

      let duplicateDomains = false,
        duplicateAdditionalDomains = false;
      entry["additional-domains"]?.forEach((domain) => {
        if (domain.includes(entry.domain)) duplicateDomains = true;
        if (
          entry["additional-domains"].some((additionalDomain) =>
            domain.includes(additionalDomain)
          )
        )
          duplicateAdditionalDomains = true;
      });

      if (duplicateDomains)
        core.warning(
          "If the main domain is listed, subdomains are not necessary.",
          { file }
        );

      if (duplicateAdditionalDomains)
        core.warning("Please remove duplicate additional domains.", { file });
    })
  );

  return true;
}

main(process.argv.slice(2)).then(() => process.exit(0));
