const fs = require("fs").promises;
const core = require("@actions/core");

/**
 * A list of [ccSLDs](https://icannwiki.org/Second_Level_Domain#ccSLDs) that should be used to omit false positives from the subdomain check
 *
 * @constant
 * @type {string}
 * @default
 */
const CCSLDS = ["ac", "co", "com", "gov", "net", "org"];

/**
 * Get subdomains for a given domain
 *
 * @param {string} domain The domain to retrieve subdomains for
 * @returns {string|null} The subdomains
 */
function getSubdomains(domain) {
  const parts = domain.split(".");

  if (parts.length <= 2) return null;

  return CCSLDS.includes(parts.slice(-3)[1])
    ? parts.slice(0, -3).join(".")
    : parts.slice(0, -2).join(".");
}

async function main(files) {
  await Promise.all(
    files.map(async (file) => {
      const json = JSON.parse(await fs.readFile(file));
      const entry = json[Object.keys(json)[0]];

      // WWW prefix
      if (entry.domain.startsWith("www."))
        core.warning("Domains should not start with `www.`", { file });

      // Subdomains
      if (getSubdomains(entry.domain))
        core.warning("Consider using the base domain as the domain.", { file });

      // Additional domains
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
