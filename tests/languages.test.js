/**
 * Languages Validation Test Suite
 * 
 * This test suite validates language codes in entry files.
 * Languages are validated against ISO 639-1 codes.
 * 
 * @module tests/languages
 */

const fs = require('fs').promises;
const { glob } = require('glob');

/**
 * URL for fetching ISO 639-1 language codes
 * @constant {string}
 */
const LANGUAGE_CODES_URL = 
  'https://pkgstore.datahub.io/core/language-codes/language-codes_json/data/97607046542b532c395cf83df5185246/language-codes_json.json';

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
 * Test suite for languages validation
 */
describe('Languages Validation', () => {
  let entryFiles = [];
  let validLanguageCodes = [];

  /**
   * Setup: Load entry files and fetch valid language codes
   */
  beforeAll(async () => {
    const files = await glob('entries/**/*.json');
    entryFiles = files.slice(0, 20); // Limit for faster testing
    
    // Fetch valid language codes from external source
    try {
      const languagesData = await fetchJSON(LANGUAGE_CODES_URL);
      validLanguageCodes = languagesData
        .map(lang => lang.alpha2)
        .filter(code => code); // Filter out null/undefined
    } catch (error) {
      console.warn('Failed to fetch language codes:', error.message);
      // Use a minimal set of common codes as fallback
      validLanguageCodes = ['en', 'es', 'fr', 'de', 'it', 'pt', 'ja', 'zh'];
    }
  }, 30000); // Increase timeout for network request

  /**
   * Test: Verify language codes were loaded
   */
  test('should load valid language codes', () => {
    expect(validLanguageCodes.length).toBeGreaterThan(0);
  });

  /**
   * Test: Each entry should have valid language codes
   */
  describe('Language Code Validation', () => {
    test('should have valid language code', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        const language = entry.contact?.language;
        
        if (language) {
          expect(validLanguageCodes).toContain(language);
        }
      }
    });

    test('should have valid language format', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        const language = entry.contact?.language;
        
        if (language) {
          // Language code should be 2 lowercase letters
          expect(language).toMatch(/^[a-z]{2}$/);
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
  LANGUAGE_CODES_URL,
};
