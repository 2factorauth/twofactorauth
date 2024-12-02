const fs = require("fs");
const { DOMParser } = require("@xmldom/xmldom");
const xpath = require("xpath");
const core = require("@actions/core");
let errors = false;

// Function to test the SVG content against an XPath expression
function test(svgContent, xpathExpression) {
  try {
    const doc = new DOMParser().parseFromString(svgContent, "application/xml");
    const nodes = xpath.select(xpathExpression, doc);
    return nodes.length > 0;
  } catch (err) {
    core.error(`Failed to parse SVG content: ${err.message}`);
    return false;
  }
}

// Function to handle file checking
async function main() {
  const files = process.argv.slice(2);

  await Promise.allSettled(
    files.map(async (file) => {
      // Skip SVG checks if the extension isn't svg
      if (!file.endsWith(".svg")) return;

      const error = (msg) => {
        core.error(msg, { file });
        errors = true;
      };

      const warn = (msg) => {
        core.warning(msg, { file });
      };

      const svg = fs.readFileSync(file, "utf8");
      const doc = new DOMParser().parseFromString(svg, "application/xml");
      const parseErrors = doc.getElementsByTagName("parsererror");

      if (parseErrors.length > 0) error("Invalid SVG file");
      if (svg.includes("<?")) error("Unnecessary processing instruction found");
      if (test(svg, "//image")) error("Embedded image detected");
      if (svg.split("\n").filter((line) => line.trim()).length > 1)
        error("Minimize file to one line");
      if (test(svg, "//comment()")) warn("Remove comments");
      if (fs.statSync(file).size > 5 * 1024) warn("Unusually large file size");
      if (
        test(
          svg,
          '//@*[(starts-with(name(), "data-") or starts-with(name(), "class-"))]'
        )
      )
        warn("Unnecessary data or class attribute");
      if (test(svg, "//@width | //@height"))
        warn("Use viewBox instead of height/width");
      if (test(svg, "/*/@id")) warn("Unnecessary id attribute in root element");
      if (test(svg, '//*[@fill="#000" or @fill="#000000"]'))
        warn('Unnecessary fill="#000" attribute');
      if (test(svg, "//*[@style]"))
        warn("Use attributes instead of style elements");
      if (test(svg, "//*[@fill-opacity]"))
        warn("Use hex color instead of fill-opacity");
      if (svg.includes("xml:space"))
        warn("Unnecessary XML:space declaration found");
      if (
        test(
          svg,
          "//*[@version or @fill-rule or @script or @a or @clipPath or @class]"
        )
      )
        warn(
          "Unnecessary attribute(s) found: version, fill-rule, script, a, clipPath, or class"
        );
    })
  );
  process.exit(+errors);
}

module.exports = main();
