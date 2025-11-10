/**
 * Regions Validation Test Suite
 * 
 * This test suite validates region codes in entry files.
 * Regions are validated against ISO 3166-1 alpha-2 codes.
 * 
 * @module tests/regions
 */

const fs = require('fs').promises;
const { glob } = require('glob');

/**
 * URL for fetching ISO 3166-1 alpha-2 region codes
 * @constant {string}
 */
const REGION_CODES_URL = 
  'https://raw.githubusercontent.com/stefangabos/world_countries/master/data/countries/en/world.json';

/**
 * Fetch and parse JSON from URL
 * 
 * @param {string} url - URL to fetch from
 * @returns {Promise<Object>} Parsed JSON data
 */
async function fetchJSON(url) {
  const response = await fetch(url, {
    headers: {
      'accept': 'application/json',
      'user-agent': '2factorauth/twofactorauth +https://2fa.directory/bots',
    },
  });
  
  if (!response.ok) {
    throw new Error(`Failed to fetch ${url}: ${response.statusText}`);
  }
  
  return response.json();
}

/**
 * Test suite for regions validation
 */
describe('Regions Validation', () => {
  let entryFiles = [];
  let validRegionCodes = [];

  /**
   * Setup: Load entry files and fetch valid region codes
   */
  beforeAll(async () => {
    const files = await glob('entries/**/*.json');
    entryFiles = files.slice(0, 20); // Limit for faster testing
    
    // Fetch valid region codes from external source
    try {
      const regionsData = await fetchJSON(REGION_CODES_URL);
      validRegionCodes = regionsData.map(region => region.alpha2.toLowerCase());
    } catch (error) {
      console.warn('Failed to fetch region codes:', error.message);
      // Use a minimal set of common codes as fallback
      validRegionCodes = ['us', 'gb', 'ca', 'au', 'de', 'fr', 'jp', 'cn'];
    }
  }, 30000); // Increase timeout for network request

  /**
   * Test: Verify region codes were loaded
   */
  test('should load valid region codes', () => {
    expect(validRegionCodes.length).toBeGreaterThan(0);
  });

  /**
   * Test: Each entry should have valid region codes
   */
  describe('Region Code Validation', () => {
    test('should have valid region codes', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        const { regions } = entry;
        
        if (regions && Array.isArray(regions)) {
          for (const region of regions) {
            // Remove leading '-' for exclusion regions
            const regionCode = region.replace('-', '').toLowerCase();
            
            expect(validRegionCodes).toContain(regionCode);
          }
        }
      }
    });

    test('should have valid region format', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        const { regions } = entry;
        
        if (regions && Array.isArray(regions)) {
          for (const region of regions) {
            // Region should be 2 letters, optionally prefixed with '-'
            expect(region).toMatch(/^-?[a-z]{2}$/i);
          }
        }
      }
    });
  });
});

/**
 * Export helper functions for use in other tests
 */
module.exports = {
  fetchJSON,
  REGION_CODES_URL,
};
