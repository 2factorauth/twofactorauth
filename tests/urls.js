const fs = require("fs").promises;
const core = require("@actions/core");
const AbortController = require("abort-controller");

// Helper function to create a timeout promise
function timeout(ms) {
  return new Promise((_, reject) =>
    setTimeout(() => reject(new Error("timeout")), ms),
  );
}

async function checkURL(url, file) {
  const controller = new AbortController();
  const signal = controller.signal;

  try {
    const res = await Promise.race([
      fetch(url, {
        headers: {
          "User-Agent":
            "2factorauth/URLValidator (+https://2fa.directory/bots)",
        },
        signal,
      }),
      timeout(2000).then(() => controller.abort()),
    ]);

    if (res.ok) return true;
    else if (res.status !== 403)
      core.warning(`Unable to fetch ${url} (${res.status})`, { file });
  } catch (e) {
    core.warning(`Unable to fetch ${url}`, { file });
  }
  return false;
}

async function main(files) {
  await Promise.all(
    files.map(async (file) => {
      const json = JSON.parse(await fs.readFile(file));
      const entry = json[Object.keys(json)[0]];
      let urls = [entry.url ? entry.url : `https://${entry.domain}/`];

      entry["additional-domains"]?.forEach((domain) =>
        urls.push(`https://${domain}/`),
      );

      await Promise.all(urls.map((url) => checkURL(url, file)));
    }),
  );

  return true;
}

main(process.argv.slice(2)).then(() => process.exit(0));
