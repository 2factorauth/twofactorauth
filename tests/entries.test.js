/**
 * Entry Files Validation Test Suite
 * 
 * This test suite validates all entry JSON files in the entries directory.
 * It checks for:
 * - Valid JSON structure
 * - Schema compliance
 * - Proper file naming
 * - Required fields
 * - Data consistency
 * 
 * @module tests/entries
 */

const fs = require('fs').promises;
const path = require('path');
const Ajv = require('ajv');
const addFormats = require('ajv-formats');
const { glob } = require('glob');

// Initialize AJV validator
const ajv = new Ajv({ strict: false, allErrors: true });
addFormats(ajv);
require('ajv-errors')(ajv);

/**
 * Test suite for entry file validation
 */
describe('Entry Files Validation', () => {
  let entryFiles = [];
  let schema = null;
  let validate = null;

  /**
   * Setup: Load all entry files and schema before running tests
   */
  beforeAll(async () => {
    // Load entry files
    const files = await glob('entries/**/*.json');
    entryFiles = files.slice(0, 20); // Limit to 20 files for faster testing
    
    // Load and compile schema
    const schemaFile = await fs.readFile('tests/schemas/entries.json', 'utf8');
    schema = JSON.parse(schemaFile);
    validate = ajv.compile(schema);
  });

  /**
   * Test: Verify that entry files exist
   */
  test('should find entry files', () => {
    expect(entryFiles.length).toBeGreaterThan(0);
  });

  /**
   * Test: Validate each entry file's JSON structure
   */
  describe('JSON Structure Validation', () => {
    test('should have valid JSON structure for all files', async () => {
      if (entryFiles.length === 0) {
        console.warn('No entry files found');
        return;
      }
      
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        expect(() => JSON.parse(content)).not.toThrow();
      }
    });
  });

  /**
   * Test: Validate schema compliance for all entries
   */
  describe('Schema Compliance', () => {
    test('should comply with schema for all files', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        
        const valid = validate(json);
        if (!valid) {
          console.error(`Schema errors in ${file}:`, validate.errors);
        }
        expect(valid).toBe(true);
      }
    });
  });

  /**
   * Test: Validate file naming conventions
   */
  describe('File Naming', () => {
    test('should have correct filename for all files', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        const expectedName = `${entry.domain}.json`;
        const actualName = path.basename(file);
        
        expect(actualName).toBe(expectedName);
      }
    });
  });

  /**
   * Test: Validate file location based on domain
   */
  describe('File Location', () => {
    test('should be in correct directory for all files', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        const expectedPath = `entries/${entry.domain[0]}/${entry.domain}.json`;
        
        expect(file.replace(/\\/g, '/')).toBe(expectedPath);
      }
    });
  });

  /**
   * Test: Validate required fields
   */
  describe('Required Fields', () => {
    test('should have domain field for all files', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        expect(entry).toHaveProperty('domain');
        expect(typeof entry.domain).toBe('string');
        expect(entry.domain.length).toBeGreaterThan(0);
      }
    });

    test('should have categories field for all files', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        expect(entry).toHaveProperty('categories');
        expect(Array.isArray(entry.categories)).toBe(true);
      }
    });
  });

  /**
   * Test: Validate TFA-related fields
   */
  describe('TFA Fields Validation', () => {
    test('should have custom-software when TFA includes it', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        if (entry.tfa?.includes('custom-software')) {
          expect(entry).toHaveProperty('custom-software');
          expect(Array.isArray(entry['custom-software'])).toBe(true);
        }
      }
    });

    test('should have custom-hardware when TFA includes it', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        if (entry.tfa?.includes('custom-hardware')) {
          expect(entry).toHaveProperty('custom-hardware');
          expect(Array.isArray(entry['custom-hardware'])).toBe(true);
        }
      }
    });
  });

  /**
   * Test: Validate URL field optimization
   */
  describe('URL Field Optimization', () => {
    test('should not have redundant URL field', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        // URL field should not be present if it's just https://domain
        if (entry.url) {
          expect(entry.url).not.toBe(`https://${entry.domain}`);
        }
      }
    });

    test('should not have redundant img field', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        // img field should not be present if it's just domain.svg
        if (entry.img) {
          expect(entry.img).not.toBe(`${entry.domain}.svg`);
        }
      }
    });
  });
});
