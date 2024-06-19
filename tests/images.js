const fs = require("fs").promises;
const core = require("@actions/core");
const { glob } = require("glob");

// Allowed image dimensions
const PNG_RES = [
  [16, 16],
  [32, 32],
  [64, 64],
  [128, 128],
];

let seenImages = [];
let errors = false;

async function main() {
  const [entries, images] = await Promise.all([
    glob("entries/**/*.json"),
    glob("img/*/*.*"),
  ]);

  await parseEntries(entries);
  await parseImages(images);

  process.exit(+errors);
}

async function parseEntries(entries) {
  await Promise.all(
    entries.map(async (file) => {
      const data = await fs.readFile(file, "utf8");
      const json = await JSON.parse(data);
      const entry = json[Object.keys(json)[0]];
      const { img, domain } = entry;
      const path = `img/${img ? `${img[0]}/${img}` : `${domain[0]}/${domain}.svg`}`;

      try {
        await fs.readFile(path);
      } catch (e) {
        core.error(`Image ${path} not found.`, { file });
        errors = true;
      }
      seenImages.push(path);
    }),
  );
}

async function parseImages(images) {
  await Promise.all(
    images.map(async (image) => {
      if (!seenImages.includes(image)) {
        core.error(`Unused image`, { file: image });
        errors = true;
      }

      if (image.endsWith(".png")) {
        if (!dimensionsAreValid(await getPNGDimensions(image), PNG_RES)) {
          core.error(
            `PNGs must be one of the following dimensions: ${PNG_RES.map((a) =>
              a.join("x"),
            ).join(", ")}`,
            { file: image },
          );
          errors = true;
        }
      }
    }),
  );
}

function dimensionsAreValid(dimensions, validSizes) {
  return validSizes.some(
    (size) => size[0] === dimensions[0] && size[1] === dimensions[1],
  );
}

async function getPNGDimensions(file) {
  const buffer = await fs.readFile(file);
  if (buffer.toString("ascii", 1, 4) !== "PNG")
    throw new Error(`${file} is not a valid PNG file`);

  // Return [width, height]
  return [buffer.readUInt32BE(16), buffer.readUInt32BE(20)];
}

main().catch((e) => core.setFailed(e));
