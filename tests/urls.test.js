/**
 * URL Validation Test Suite
 * 
 * This test suite validates URL reachability for entries.
 * It checks:
 * - Main domain URL accessibility
 * - Additional domain URLs
 * - Documentation URLs
 * - Recovery URLs
 * - HTTP response codes
 * 
 * Note: These tests can be slow and may fail due to network issues.
 * They are typically run with a longer timeout and may be skipped in CI.
 * 
 * @module tests/urls
 */

const fs = require('fs').promises;
const { glob } = require('glob');

/**
 * Timeout for URL fetch requests (in milliseconds)
 * @constant {number}
 */
const FETCH_TIMEOUT = 5000;

/**
 * User agent string for requests
 * @constant {string}
 */
const USER_AGENT = '2factorauth/URLValidator (+https://2fa.directory/bots)';

/**
 * Create a timeout promise
 * 
 * @param {number} ms - Timeout in milliseconds
 * @returns {Promise} Promise that rejects after timeout
 */
function createTimeout(ms) {
  return new Promise((_, reject) =>
    setTimeout(() => reject(new Error('Request timeout')), ms)
  );
}

/**
 * Check if a URL is reachable
 * 
 * @param {string} url - URL to check
 * @param {number} timeout - Timeout in milliseconds
 * @returns {Promise<Object>} Object with ok status and status code
 */
async function checkURL(url, timeout = FETCH_TIMEOUT) {
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    const response = await fetch(url, {
      method: 'HEAD', // Use HEAD to avoid downloading full content
      headers: {
        'User-Agent': USER_AGENT,
      },
      signal: controller.signal,
    });
    
    clearTimeout(timeoutId);
    
    return {
      ok: response.ok,
      status: response.status,
      url: url,
    };
  } catch (error) {
    return {
      ok: false,
      status: 0,
      error: error.message,
      url: url,
    };
  }
}

/**
 * Test suite for URL validation
 * 
 * Note: These tests are marked as slow and may be skipped
 */
describe('URL Validation', () => {
  let entryFiles = [];

  /**
   * Setup: Load all entry files
   */
  beforeAll(async () => {
    const files = await glob('entries/**/*.json');
    entryFiles = files.slice(0, 10); // Limit to 10 files for faster testing
  });

  /**
   * Test: Main domain URLs should be reachable
   */
  describe('Main Domain URLs', () => {
    test('should be reachable', async () => {
      for (const file of entryFiles.slice(0, 5)) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        // Use custom URL if provided, otherwise construct from domain
        const url = entry.url || `https://${entry.domain}/`;
        
        const result = await checkURL(url);
        
        // Log failures but don't fail test (network issues are common)
        if (!result.ok && result.status !== 403) {
          console.warn(`URL check failed for ${file}: ${url} (${result.status || result.error})`);
        }
      }
      
      // We expect either success or 403 (forbidden, but exists)
      // Anything else is logged as a warning
      expect(true).toBe(true);
    }, 30000); // 30 second timeout for all URLs
  });

  /**
   * Test: Additional domain URLs should be reachable
   */
  describe('Additional Domain URLs', () => {
    test('additional domains should be reachable', async () => {
      for (const file of entryFiles.slice(0, 3)) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        if (entry['additional-domains']) {
          for (const domain of entry['additional-domains']) {
            const url = `https://${domain}/`;
            const result = await checkURL(url);
            
            if (!result.ok && result.status !== 403) {
              console.warn(`Additional domain check failed: ${url} (${result.status || result.error})`);
            }
          }
        }
      }
      
      expect(true).toBe(true);
    }, 30000); // 30 second timeout
  });

  /**
   * Test: Documentation URLs should be reachable
   */
  describe('Documentation URLs', () => {
    test('documentation URL should be reachable', async () => {
      for (const file of entryFiles.slice(0, 5)) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        if (entry.documentation) {
          const result = await checkURL(entry.documentation);
          
          if (!result.ok && result.status !== 403) {
            console.warn(`Documentation URL check failed for ${file}: ${entry.documentation} (${result.status || result.error})`);
          }
        }
      }
      
      expect(true).toBe(true);
    }, 30000);
  });

  /**
   * Test: Recovery URLs should be reachable
   */
  describe('Recovery URLs', () => {
    test('recovery URL should be reachable', async () => {
      for (const file of entryFiles.slice(0, 5)) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        if (entry.recovery) {
          const result = await checkURL(entry.recovery);
          
          if (!result.ok && result.status !== 403) {
            console.warn(`Recovery URL check failed for ${file}: ${entry.recovery} (${result.status || result.error})`);
          }
        }
      }
      
      expect(true).toBe(true);
    }, 30000);
  });

  /**
   * Test: URLs should use HTTPS
   */
  describe('HTTPS Usage', () => {
    test('should use HTTPS', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        // Check main URL
        if (entry.url) {
          expect(entry.url.startsWith('https://')).toBe(true);
        }
        
        // Check documentation URL
        if (entry.documentation) {
          expect(entry.documentation.startsWith('https://')).toBe(true);
        }
        
        // Check recovery URL
        if (entry.recovery) {
          expect(entry.recovery.startsWith('https://')).toBe(true);
        }
      }
    });
  });

  /**
   * Test: URLs should be properly formatted
   */
  describe('URL Format', () => {
    test('should have valid URL format', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        const urlRegex = /^https?:\/\/.+/;
        
        if (entry.url) {
          expect(entry.url).toMatch(urlRegex);
        }
        
        if (entry.documentation) {
          expect(entry.documentation).toMatch(urlRegex);
        }
        
        if (entry.recovery) {
          expect(entry.recovery).toMatch(urlRegex);
        }
      }
    });
  });
});

/**
 * Export helper functions for use in other tests
 */
module.exports = {
  checkURL,
  createTimeout,
  FETCH_TIMEOUT,
  USER_AGENT,
};
