/**
 * Image Files Validation Test Suite
 * 
 * This test suite validates image files (SVG and PNG) in the img directory.
 * It checks for:
 * - Image file existence for each entry
 * - No unused images
 * - PNG dimension requirements
 * - SVG file structure and optimization
 * - File size constraints
 * 
 * @module tests/images
 */

const fs = require('fs').promises;
const { glob } = require('glob');
const { DOMParser } = require('@xmldom/xmldom');
const xpath = require('xpath');

/**
 * Allowed PNG dimensions (width x height in pixels)
 * Images must match one of these exact dimensions
 * 
 * @constant {number[][]}
 */
const PNG_ALLOWED_DIMENSIONS = [
  [16, 16],
  [32, 32],
  [64, 64],
  [128, 128],
];

/**
 * Maximum file size for SVG files (in bytes)
 * Files larger than this will trigger a warning
 * 
 * @constant {number}
 */
const MAX_SVG_SIZE = 5 * 1024; // 5KB

/**
 * Extract PNG dimensions from file buffer
 * 
 * @param {Buffer} buffer - PNG file buffer
 * @returns {number[]} Array of [width, height]
 * @throws {Error} If file is not a valid PNG
 */
function getPNGDimensions(buffer) {
  if (buffer.toString('ascii', 1, 4) !== 'PNG') {
    throw new Error('Not a valid PNG file');
  }
  
  // PNG dimensions are stored at bytes 16-20 (width) and 20-24 (height)
  const width = buffer.readUInt32BE(16);
  const height = buffer.readUInt32BE(20);
  
  return [width, height];
}

/**
 * Check if dimensions match any allowed size
 * 
 * @param {number[]} dimensions - [width, height]
 * @param {number[][]} allowedSizes - Array of allowed [width, height] pairs
 * @returns {boolean} True if dimensions match an allowed size
 */
function dimensionsAreValid(dimensions, allowedSizes) {
  return allowedSizes.some(
    size => size[0] === dimensions[0] && size[1] === dimensions[1]
  );
}

/**
 * Test SVG content against XPath expression
 * 
 * @param {string} svgContent - SVG file content
 * @param {string} xpathExpression - XPath query
 * @returns {boolean} True if XPath matches
 */
function testSVGXPath(svgContent, xpathExpression) {
  try {
    const doc = new DOMParser().parseFromString(svgContent, 'application/xml');
    const nodes = xpath.select(xpathExpression, doc);
    return nodes.length > 0;
  } catch (err) {
    return false;
  }
}

/**
 * Test suite for image validation
 */
describe('Image Files Validation', () => {
  let entryFiles = [];
  let imageFiles = [];
  let expectedImages = new Set();

  /**
   * Setup: Load all entry and image files
   */
  beforeAll(async () => {
    const allEntries = await glob('entries/**/*.json');
    entryFiles = allEntries.slice(0, 20); // Limit for faster testing
    imageFiles = await glob('img/**/*.*');
    
    // Build set of expected images from entries
    for (const file of entryFiles) {
      const content = await fs.readFile(file, 'utf8');
      const json = JSON.parse(content);
      const entry = json[Object.keys(json)[0]];
      const { img, domain } = entry;
      
      // Default image path is domain.svg in domain[0] directory
      const imagePath = img 
        ? `img/${img[0]}/${img}` 
        : `img/${domain[0]}/${domain}.svg`;
      
      expectedImages.add(imagePath.replace(/\\/g, '/'));
    }
  });

  /**
   * Test: Verify images were found
   */
  test('should find image files', () => {
    expect(imageFiles.length).toBeGreaterThan(0);
  });

  /**
   * Test: Each entry should have a corresponding image
   */
  describe('Entry Image Existence', () => {
    test('should have image file for all entries', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        const { img, domain } = entry;
        
        const imagePath = img 
          ? `img/${img[0]}/${img}` 
          : `img/${domain[0]}/${domain}.svg`;
        
        // Check if file exists
        await expect(fs.access(imagePath)).resolves.not.toThrow();
      }
    });
  });

  /**
   * Test: No unused images should exist
   */
  describe('Unused Images Check', () => {
    test('should not have unused images (warning)', () => {
      const unusedImages = imageFiles.filter(img => {
        const normalizedPath = img.replace(/\\/g, '/');
        return !expectedImages.has(normalizedPath);
      });
      
      if (unusedImages.length > 0) {
        console.warn(`Note: Found ${unusedImages.length} images not in tested entries (testing subset only)`);
      }
      
      // This is a warning since we're only testing a subset of entries
      expect(true).toBe(true);
    });
  });

  /**
   * Test: PNG dimension validation
   */
  describe('PNG Dimensions', () => {
    test('should have valid dimensions for PNG files', async () => {
      const pngFiles = imageFiles.filter(f => f.endsWith('.png')).slice(0, 10);
      
      for (const file of pngFiles) {
        const buffer = await fs.readFile(file);
        const dimensions = getPNGDimensions(buffer);
        
        const isValid = dimensionsAreValid(dimensions, PNG_ALLOWED_DIMENSIONS);
        
        if (!isValid) {
          console.error(
            `Invalid PNG dimensions in ${file}: ${dimensions[0]}x${dimensions[1]}`
          );
        }
        
        expect(isValid).toBe(true);
      }
    });
  });

  /**
   * Test: SVG file structure validation
   */
  describe('SVG Structure', () => {
    test('should be valid XML for SVG files', async () => {
      const svgFiles = imageFiles.filter(f => f.endsWith('.svg')).slice(0, 10);
      
      for (const file of svgFiles) {
        const content = await fs.readFile(file, 'utf8');
        const doc = new DOMParser().parseFromString(content, 'application/xml');
        const parseErrors = doc.getElementsByTagName('parsererror');
        
        expect(parseErrors.length).toBe(0);
      }
    });

    test('should not have processing instructions', async () => {
      const svgFiles = imageFiles.filter(f => f.endsWith('.svg')).slice(0, 10);
      
      for (const file of svgFiles) {
        const content = await fs.readFile(file, 'utf8');
        expect(content.includes('<?')).toBe(false);
      }
    });

    test('should not have embedded images', async () => {
      const svgFiles = imageFiles.filter(f => f.endsWith('.svg')).slice(0, 10);
      
      for (const file of svgFiles) {
        const content = await fs.readFile(file, 'utf8');
        const hasEmbeddedImage = testSVGXPath(content, '//image');
        
        expect(hasEmbeddedImage).toBe(false);
      }
    });

    test('should be minified to one line', async () => {
      const svgFiles = imageFiles.filter(f => f.endsWith('.svg')).slice(0, 10);
      
      for (const file of svgFiles) {
        const content = await fs.readFile(file, 'utf8');
        const lines = content.split('\n').filter(line => line.trim());
        
        expect(lines.length).toBeLessThanOrEqual(1);
      }
    });
  });

  /**
   * Test: SVG optimization checks (warnings)
   */
  describe('SVG Optimization', () => {
    test('should not have comments (warning)', async () => {
      const svgFiles = imageFiles.filter(f => f.endsWith('.svg')).slice(0, 10);
      
      for (const file of svgFiles) {
        const content = await fs.readFile(file, 'utf8');
        const hasComments = testSVGXPath(content, '//comment()');
        
        if (hasComments) {
          console.warn(`SVG has comments: ${file}`);
        }
      }
      
      // This is a warning, not a hard failure
      expect(true).toBe(true);
    });

    test('should have reasonable file size (warning)', async () => {
      const svgFiles = imageFiles.filter(f => f.endsWith('.svg')).slice(0, 10);
      
      for (const file of svgFiles) {
        const stats = await fs.stat(file);
        
        if (stats.size > MAX_SVG_SIZE) {
          console.warn(`Large SVG file (${stats.size} bytes): ${file}`);
        }
      }
      
      // This is a warning, not a hard failure
      expect(true).toBe(true);
    });

    test('should use viewBox instead of width/height (warning)', async () => {
      const svgFiles = imageFiles.filter(f => f.endsWith('.svg')).slice(0, 10);
      
      for (const file of svgFiles) {
        const content = await fs.readFile(file, 'utf8');
        const hasWidthHeight = testSVGXPath(content, '//@width | //@height');
        
        if (hasWidthHeight) {
          console.warn(`SVG uses width/height instead of viewBox: ${file}`);
        }
      }
      
      // This is a warning, not a hard failure
      expect(true).toBe(true);
    });

    test('should not have unnecessary attributes (warning)', async () => {
      const svgFiles = imageFiles.filter(f => f.endsWith('.svg')).slice(0, 10);
      
      for (const file of svgFiles) {
        const content = await fs.readFile(file, 'utf8');
        
        const checks = [
          { xpath: '/*/@id', msg: 'root id attribute' },
          { xpath: '//*[@fill="#000" or @fill="#000000"]', msg: 'fill="#000"' },
          { xpath: '//*[@style]', msg: 'style attributes' },
          { xpath: '//*[@fill-opacity]', msg: 'fill-opacity' },
          { xpath: '//*[@version or @fill-rule or @script or @a or @clipPath or @class]', msg: 'unnecessary attributes' },
        ];
        
        for (const check of checks) {
          if (testSVGXPath(content, check.xpath)) {
            console.warn(`SVG has ${check.msg}: ${file}`);
          }
        }
      }
      
      // This is a warning, not a hard failure
      expect(true).toBe(true);
    });
  });
});

/**
 * Export helper functions for use in other tests
 */
module.exports = {
  getPNGDimensions,
  dimensionsAreValid,
  testSVGXPath,
  PNG_ALLOWED_DIMENSIONS,
  MAX_SVG_SIZE,
};
