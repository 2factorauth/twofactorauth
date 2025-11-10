/**
 * Test Utilities and Helper Functions
 * 
 * This module provides common utilities and helper functions used across
 * multiple test suites in the 2FA Directory project.
 * 
 * @module tests/test-utils
 */

const fs = require('fs').promises;
const path = require('path');

/**
 * Read and parse a JSON file
 * 
 * @param {string} filePath - Path to the JSON file
 * @returns {Promise<Object>} Parsed JSON object
 * @throws {Error} If file cannot be read or parsed
 * 
 * @example
 * const data = await readJSONFile('entries/a/adobe.com.json');
 */
async function readJSONFile(filePath) {
  const content = await fs.readFile(filePath, 'utf8');
  return JSON.parse(content);
}

/**
 * Write a JSON object to a file with formatting
 * 
 * @param {string} filePath - Path to write the file
 * @param {Object} data - Data to write
 * @param {number} indent - Number of spaces for indentation (default: 2)
 * @returns {Promise<void>}
 * 
 * @example
 * await writeJSONFile('output.json', { key: 'value' });
 */
async function writeJSONFile(filePath, data, indent = 2) {
  const content = JSON.stringify(data, null, indent);
  await fs.writeFile(filePath, content, 'utf8');
}

/**
 * Check if a file exists
 * 
 * @param {string} filePath - Path to check
 * @returns {Promise<boolean>} True if file exists
 * 
 * @example
 * if (await fileExists('test.json')) { ... }
 */
async function fileExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

/**
 * Get the size of a file in bytes
 * 
 * @param {string} filePath - Path to the file
 * @returns {Promise<number>} File size in bytes
 * 
 * @example
 * const size = await getFileSize('image.svg');
 */
async function getFileSize(filePath) {
  const stats = await fs.stat(filePath);
  return stats.size;
}

/**
 * Extract entry data from a JSON file
 * 
 * Entry files have a single top-level key (the service name)
 * with the entry data as its value.
 * 
 * @param {string} filePath - Path to entry file
 * @returns {Promise<Object>} Object with name and entry data
 * 
 * @example
 * const { name, entry } = await getEntryData('entries/a/adobe.com.json');
 * // name: "Adobe ID"
 * // entry: { domain: "adobe.com", ... }
 */
async function getEntryData(filePath) {
  const json = await readJSONFile(filePath);
  const name = Object.keys(json)[0];
  const entry = json[name];
  
  return { name, entry };
}

/**
 * Get the expected image path for an entry
 * 
 * @param {Object} entry - Entry data object
 * @returns {string} Expected image file path
 * 
 * @example
 * const imagePath = getExpectedImagePath(entry);
 * // Returns: "img/a/adobe.com.svg" or custom path if specified
 */
function getExpectedImagePath(entry) {
  const { img, domain } = entry;
  
  if (img) {
    return `img/${img[0]}/${img}`;
  }
  
  return `img/${domain[0]}/${domain}.svg`;
}

/**
 * Validate domain format using regex
 * 
 * @param {string} domain - Domain to validate
 * @returns {boolean} True if domain format is valid
 * 
 * @example
 * isValidDomain('example.com') // true
 * isValidDomain('www.example.com') // true
 * isValidDomain('invalid..com') // false
 */
function isValidDomain(domain) {
  const domainRegex = /^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*\.[a-z]{2,}$/i;
  return domainRegex.test(domain);
}

/**
 * Validate URL format
 * 
 * @param {string} url - URL to validate
 * @returns {boolean} True if URL format is valid
 * 
 * @example
 * isValidURL('https://example.com') // true
 * isValidURL('not-a-url') // false
 */
function isValidURL(url) {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
}

/**
 * Check if a string is a valid ISO 639-1 language code format
 * 
 * @param {string} code - Language code to check
 * @returns {boolean} True if format is valid (2 lowercase letters)
 * 
 * @example
 * isValidLanguageCodeFormat('en') // true
 * isValidLanguageCodeFormat('EN') // false
 * isValidLanguageCodeFormat('eng') // false
 */
function isValidLanguageCodeFormat(code) {
  return /^[a-z]{2}$/.test(code);
}

/**
 * Check if a string is a valid ISO 3166-1 alpha-2 region code format
 * 
 * @param {string} code - Region code to check (may have '-' prefix)
 * @returns {boolean} True if format is valid
 * 
 * @example
 * isValidRegionCodeFormat('us') // true
 * isValidRegionCodeFormat('-us') // true (exclusion)
 * isValidRegionCodeFormat('USA') // false
 */
function isValidRegionCodeFormat(code) {
  return /^-?[a-z]{2}$/i.test(code);
}

/**
 * Normalize file path for cross-platform compatibility
 * 
 * @param {string} filePath - File path to normalize
 * @returns {string} Normalized path with forward slashes
 * 
 * @example
 * normalizePath('entries\\a\\adobe.com.json')
 * // Returns: 'entries/a/adobe.com.json'
 */
function normalizePath(filePath) {
  return filePath.replace(/\\/g, '/');
}

/**
 * Group array items by a key function
 * 
 * @param {Array} array - Array to group
 * @param {Function} keyFn - Function to extract key from item
 * @returns {Object} Object with grouped items
 * 
 * @example
 * const entries = [{ domain: 'a.com' }, { domain: 'b.com' }];
 * const grouped = groupBy(entries, e => e.domain[0]);
 * // Returns: { a: [{ domain: 'a.com' }], b: [{ domain: 'b.com' }] }
 */
function groupBy(array, keyFn) {
  return array.reduce((result, item) => {
    const key = keyFn(item);
    if (!result[key]) {
      result[key] = [];
    }
    result[key].push(item);
    return result;
  }, {});
}

/**
 * Retry an async function with exponential backoff
 * 
 * @param {Function} fn - Async function to retry
 * @param {number} maxRetries - Maximum number of retries (default: 3)
 * @param {number} delay - Initial delay in ms (default: 1000)
 * @returns {Promise<any>} Result of the function
 * 
 * @example
 * const result = await retry(() => fetchData(), 3, 1000);
 */
async function retry(fn, maxRetries = 3, delay = 1000) {
  let lastError;
  
  for (let i = 0; i <= maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      
      if (i < maxRetries) {
        await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, i)));
      }
    }
  }
  
  throw lastError;
}

/**
 * Create a mock entry object for testing
 * 
 * @param {Object} overrides - Properties to override defaults
 * @returns {Object} Mock entry object
 * 
 * @example
 * const entry = createMockEntry({ domain: 'test.com' });
 */
function createMockEntry(overrides = {}) {
  return {
    domain: 'example.com',
    categories: ['other'],
    tfa: ['sms'],
    documentation: 'https://example.com/docs',
    ...overrides,
  };
}

/**
 * Batch process array items with concurrency limit
 * 
 * @param {Array} items - Items to process
 * @param {Function} processor - Async function to process each item
 * @param {number} concurrency - Maximum concurrent operations (default: 5)
 * @returns {Promise<Array>} Results array
 * 
 * @example
 * const results = await batchProcess(files, async (file) => {
 *   return await processFile(file);
 * }, 5);
 */
async function batchProcess(items, processor, concurrency = 5) {
  const results = [];
  const executing = [];
  
  for (const item of items) {
    const promise = processor(item).then(result => {
      executing.splice(executing.indexOf(promise), 1);
      return result;
    });
    
    results.push(promise);
    executing.push(promise);
    
    if (executing.length >= concurrency) {
      await Promise.race(executing);
    }
  }
  
  return Promise.all(results);
}

/**
 * Format bytes to human-readable string
 * 
 * @param {number} bytes - Number of bytes
 * @param {number} decimals - Number of decimal places (default: 2)
 * @returns {string} Formatted string (e.g., "1.5 KB")
 * 
 * @example
 * formatBytes(1536) // "1.50 KB"
 * formatBytes(1048576) // "1.00 MB"
 */
function formatBytes(bytes, decimals = 2) {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(decimals)) + ' ' + sizes[i];
}

/**
 * Deep clone an object
 * 
 * @param {Object} obj - Object to clone
 * @returns {Object} Cloned object
 * 
 * @example
 * const cloned = deepClone(original);
 */
function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

// Export all utilities
module.exports = {
  readJSONFile,
  writeJSONFile,
  fileExists,
  getFileSize,
  getEntryData,
  getExpectedImagePath,
  isValidDomain,
  isValidURL,
  isValidLanguageCodeFormat,
  isValidRegionCodeFormat,
  normalizePath,
  groupBy,
  retry,
  createMockEntry,
  batchProcess,
  formatBytes,
  deepClone,
};
