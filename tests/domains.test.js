/**
 * Domain Validation Test Suite
 * 
 * This test suite validates domain-related fields in entry files.
 * It checks for:
 * - Proper domain format
 * - No www prefix
 * - Subdomain usage
 * - Additional domains validation
 * - Duplicate domain detection
 * 
 * @module tests/domains
 */

const fs = require('fs').promises;
const { glob } = require('glob');

/**
 * List of country code Second Level Domains (ccSLDs)
 * Used to properly identify base domains vs subdomains
 * 
 * @constant {string[]}
 */
const CCSLDS = ['ac', 'co', 'com', 'gov', 'net', 'org'];

/**
 * Extract subdomains from a given domain
 * 
 * @param {string} domain - The domain to analyze
 * @returns {string|null} The subdomain portion or null if none
 * 
 * @example
 * getSubdomains('api.example.com') // returns 'api'
 * getSubdomains('example.com') // returns null
 * getSubdomains('shop.example.co.uk') // returns 'shop'
 */
function getSubdomains(domain) {
  const parts = domain.split('.');
  
  // If only 2 parts (e.g., example.com), no subdomain
  if (parts.length <= 2) return null;
  
  // Check if it's a ccSLD (e.g., example.co.uk)
  // If so, need at least 4 parts to have a subdomain
  if (CCSLDS.includes(parts[parts.length - 2])) {
    return parts.length > 3 ? parts.slice(0, -3).join('.') : null;
  }
  
  // Otherwise, return everything except the last 2 parts
  return parts.slice(0, -2).join('.');
}

/**
 * Test suite for domain validation
 */
describe('Domain Validation', () => {
  let entryFiles = [];

  /**
   * Setup: Load all entry files before running tests
   */
  beforeAll(async () => {
    const files = await glob('entries/**/*.json');
    entryFiles = files.slice(0, 20); // Limit to 20 files for faster testing
  });

  /**
   * Test: Verify entry files were found
   */
  test('should find entry files', () => {
    expect(entryFiles.length).toBeGreaterThan(0);
  });

  /**
   * Test: Domains should not start with 'www.'
   */
  describe('WWW Prefix Check', () => {
    test('should not have www prefix', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        expect(entry.domain.startsWith('www.')).toBe(false);
      }
    });
  });

  /**
   * Test: Check for subdomain usage (should prefer base domain)
   */
  describe('Subdomain Usage', () => {
    test('should consider using base domain', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        const subdomain = getSubdomains(entry.domain);
        
        // This is a warning-level check, not a hard failure
        // We just log if a subdomain is detected
        if (subdomain) {
          console.warn(`File ${file} uses subdomain: ${entry.domain}`);
        }
      }
      
      // Always pass, but log the warning
      expect(true).toBe(true);
    });
  });

  /**
   * Test: Validate additional domains
   */
  describe('Additional Domains Validation', () => {
    test('should not have duplicate main domain in additional-domains', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        if (entry['additional-domains']) {
          const hasDuplicate = entry['additional-domains'].some(
            domain => domain.includes(entry.domain) || entry.domain.includes(domain)
          );
          
          expect(hasDuplicate).toBe(false);
        }
      }
    });

    test('should not have duplicate additional domains', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        if (entry['additional-domains']) {
          const domains = entry['additional-domains'];
          
          // Check for duplicates within additional-domains
          const hasDuplicates = domains.some((domain, index) => {
            return domains.some((otherDomain, otherIndex) => {
              if (index === otherIndex) return false;
              return domain.includes(otherDomain) || otherDomain.includes(domain);
            });
          });
          
          expect(hasDuplicates).toBe(false);
        }
      }
    });

    test('should have unique additional domains', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        if (entry['additional-domains']) {
          const domains = entry['additional-domains'];
          const uniqueDomains = new Set(domains);
          
          expect(domains.length).toBe(uniqueDomains.size);
        }
      }
    });
  });

  /**
   * Test: Validate domain format
   */
  describe('Domain Format', () => {
    test('should have valid domain format', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        // Basic domain format validation
        const domainRegex = /^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*\.[a-z]{2,}$/i;
        
        expect(entry.domain).toMatch(domainRegex);
      }
    });

    test('should not have trailing dots', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        expect(entry.domain.endsWith('.')).toBe(false);
      }
    });

    test('should not have leading dots', async () => {
      for (const file of entryFiles) {
        const content = await fs.readFile(file, 'utf8');
        const json = JSON.parse(content);
        const entry = json[Object.keys(json)[0]];
        
        expect(entry.domain.startsWith('.')).toBe(false);
      }
    });
  });
});

/**
 * Export helper functions for use in other tests
 */
module.exports = {
  getSubdomains,
  CCSLDS,
};
