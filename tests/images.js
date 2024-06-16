const fs = require('fs').promises;
const core = require('@actions/core');
const {glob} = require('glob');

// Allowed image dimensions
const PNG_RES = [
  [16, 16], [32, 32], [64, 64], [128, 128]];

let seen_images = [];
let errors = false;

async function main() {

  await parseEntries(await glob('entries/**/*.json'));

  await parseImages(await glob('img/*/*.*'));

  process.exit(+errors);
}

async function parseEntries(entries) {
  for (const file of entries) {
    const data = await fs.readFile(file, 'utf8');
    const json = await JSON.parse(data);
    const entry = json[Object.keys(json)[0]];
    const {img, domain} = entry;
    const path = `img/${img ? `${img[0]}/${img}`:`${domain[0]}/${domain}.svg`}`;

    try {
      await fs.readFile(path);
    } catch (e) {
      core.error(`Image ${path} not found.`, {file});
      errors = true;
    }

    if (img && img === `${domain}.svg`) {
      core.error(
        `Defining the img property for ${domain} is not necessary. ${img} is the default value.`,
        {file});
      errors = true;
    }
    seen_images.push(path);
  }
}

async function parseImages(images) {
  for (const image of images) {
    if (!seen_images.includes(image)) {
      core.error(`Unused image`, {file: image});
      errors = true;
    }

    if (image.endsWith('.png')) {
      if (!dimensionsAreValid(await getPNGDimensions(image), PNG_RES)) {
        core.error(`PNGs must be one of the following dimensions: ${PNG_RES.map(
          a => a.join('x')).join(', ')}`, {file: image});
      }
    }
  }
}

function dimensionsAreValid(dimensions, validSizes) {
  return validSizes.some(
    size => size[0] === dimensions[0] && size[1] === dimensions[1]);
}

async function getPNGDimensions(file) {
  const buffer = await fs.readFile(file);
  if (buffer.toString('ascii', 1, 4) !== 'PNG') throw new Error(
    `${file} is not a valid PNG file`);

  // Return [width, height]
  return [buffer.readUInt32BE(16), buffer.readUInt32BE(20)];
}

main().catch(e => core.setFailed(e));
