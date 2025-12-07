/**
 * Jest Configuration for 2FA Directory Project
 * 
 * This configuration file sets up Jest testing framework for the project.
 * It includes settings for test coverage, test environment, and test patterns.
 * 
 * @see https://jestjs.io/docs/configuration
 */

module.exports = {
  // The test environment that will be used for testing
  testEnvironment: 'node',

  // The glob patterns Jest uses to detect test files
  testMatch: [
    '**/tests/**/*.test.js',
    '**/tests/**/*.spec.js',
  ],

  // An array of regexp pattern strings used to skip coverage collection
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/api/',
    '/img/',
  ],

  // Indicates which provider should be used to instrument code for coverage
  coverageProvider: 'v8',

  // A list of reporter names that Jest uses when writing coverage reports
  coverageReporters: [
    'text',
    'lcov',
    'html',
  ],

  // The directory where Jest should output its coverage files
  coverageDirectory: 'coverage',

  // Automatically clear mock calls and instances between every test
  clearMocks: true,

  // The maximum amount of workers used to run your tests
  maxWorkers: '50%',

  // A map from regular expressions to module names that allow to stub out resources
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
    '^@tests/(.*)$': '<rootDir>/tests/$1',
    '^@scripts/(.*)$': '<rootDir>/scripts/$1',
  },

  // Indicates whether each individual test should be reported during the run
  verbose: true,

  // An array of regexp pattern strings that are matched against all test paths before executing the test
  testPathIgnorePatterns: [
    '/node_modules/',
    '/api/',
  ],

  // The number of seconds after which a test is considered as slow and reported as such
  slowTestThreshold: 10,

  // Timeout for tests in milliseconds
  testTimeout: 30000,
};
