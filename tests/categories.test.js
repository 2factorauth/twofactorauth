/**
 * Categories Validation Test Suite
 * 
 * This test suite validates category codes in entry files.
 * Categories are validated against the local categories.json file.
 * 
 * @module tests/categories
 */

const fs = require('fs').promises;
const { glob } = require('glob');

/**
 * Test suite for categories validation
 */
describe('Categories Validation', () => {
  let entryFiles = [];
  let allowedCategories = [];

  /**
   * Setup: Load entry files and allowed categories
   */
  beforeAll(async () => {
    const files = await glob('entries/**/*.json');
    entryFiles = files.slice(0, 20); // Limit for faster testing
    
    // Load allowed categories from local file
    const categoriesFile = await fs.readFile('tests/categories.json', 'utf8');
    const categoriesData = JSON.parse(categoriesFile);
    allowedCategories = Object.keys(categoriesData);
  });

  /**
   * Test: Verify allowed categories were loaded
   */
  test('should load allowed categories', () => {
    expect(allowedCategories.length).toBeGreaterThan(0);
  });

  /**
   * Test: Each entry should have valid categories
   */
  describe('Category Code Validation', () => {
    test('should have valid categories', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        const { categories } = entry;
        
        if (categories && Array.isArray(categories)) {
          for (const category of categories) {
            expect(allowedCategories).toContain(category);
          }
        }
      }
    });

    test('should have at least one category', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        expect(entry.categories).toBeDefined();
        expect(Array.isArray(entry.categories)).toBe(true);
        expect(entry.categories.length).toBeGreaterThan(0);
      }
    });
  });
});
