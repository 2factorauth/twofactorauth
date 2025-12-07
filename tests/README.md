# 2FA Directory - Testing Documentation

This directory contains comprehensive test suites for the 2FA Directory project using Jest.

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Overview](#overview)
- [Test Suites](#test-suites)
- [Setup](#setup)
- [Running Tests](#running-tests)
- [Test Configuration](#test-configuration)
- [Writing Tests](#writing-tests)
- [Continuous Integration](#continuous-integration)
- [Common Scenarios](#common-scenarios)
- [Troubleshooting](#troubleshooting)

## 🚀 Quick Start

### Install Dependencies

```bash
npm install
```

### Install Jest

```bash
npm install --save-dev jest
```

### Add Test Scripts to package.json

Add the following to your `package.json` under the `"scripts"` section:

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:entries": "jest entries.test.js",
    "test:domains": "jest domains.test.js",
    "test:images": "jest images.test.js",
    "test:codes": "jest categories-regions-languages.test.js",
    "test:urls": "jest urls.test.js",
    "test:api": "jest api-generation.test.js",
    "test:verbose": "jest --verbose",
    "test:ci": "jest --ci --coverage --maxWorkers=2"
  }
}
```

### Run Tests

```bash
# Run all tests
npm test

# Run specific test suite
npm run test:entries

# Run with coverage
npm run test:coverage

# Watch mode for development
npm run test:watch
```

### Test Suite Overview

| Test Suite | File | Purpose | Speed |
|------------|------|---------|-------|
| Entry Validation | `entries.test.js` | Validates JSON structure and schema | Fast |
| Domain Validation | `domains.test.js` | Validates domain formats | Fast |
| Image Validation | `images.test.js` | Validates SVG/PNG files | Medium |
| Code Validation | `categories-regions-languages.test.js` | Validates category/region/language codes | Medium |
| URL Validation | `urls.test.js` | Checks URL reachability | Slow |
| API Generation | `api-generation.test.js` | Validates API output | Medium |

## 🔍 Overview

The testing infrastructure validates:
- **Entry Files**: JSON structure, schema compliance, and data integrity
- **Domains**: Format validation, subdomain checks, and duplicate detection
- **Images**: SVG/PNG validation, dimensions, and optimization
- **Categories/Regions/Languages**: Code validation against external standards
- **URLs**: Reachability and format validation
- **API Generation**: Output validation and schema compliance

## 🧪 Test Suites

### `entries.test.js`
Validates all entry JSON files for:
- Valid JSON structure
- Schema compliance (using AJV)
- Proper file naming conventions
- Required fields presence
- TFA-related field consistency
- URL and image field optimization

### `domains.test.js`
Validates domain-related fields:
- No `www.` prefix
- Subdomain usage warnings
- Additional domains validation
- Duplicate domain detection
- Domain format validation

### `images.test.js`
Validates image files:
- Image existence for each entry
- No unused images
- PNG dimension requirements (16x16, 32x32, 64x64, 128x128)
- SVG structure and optimization
- File size constraints

### `categories-regions-languages.test.js`
Validates codes against external standards:
- **Categories**: Against local `categories.json`
- **Regions**: Against ISO 3166-1 alpha-2 codes
- **Languages**: Against ISO 639-1 codes

### `urls.test.js`
Validates URL accessibility:
- Main domain reachability
- Additional domains
- Documentation URLs
- Recovery URLs
- HTTPS usage
- URL format validation

### `api-generation.test.js`
Validates API generation:
- API v3 generation and schema compliance
- API v4 generation and schema compliance
- Frontend API v1 generation
- Data integrity and consistency

## 🚀 Setup

### Prerequisites

```bash
# Install Node.js 20 or higher
node --version  # Should be v20.x or higher

# Install dependencies
npm install
```

### Install Jest (if not already installed)

```bash
npm install --save-dev jest @types/jest
```

## ▶️ Running Tests

### Run All Tests

```bash
# Run all test suites
npm test

# Or using Jest directly
npx jest
```

### Run Specific Test Suite

```bash
# Run only entry validation tests
npx jest entries.test.js

# Run only domain tests
npx jest domains.test.js

# Run only image tests
npx jest images.test.js
```

### Run Tests with Coverage

```bash
# Generate coverage report
npx jest --coverage

# View coverage in browser
# Open coverage/lcov-report/index.html
```

### Run Tests in Watch Mode

```bash
# Automatically re-run tests on file changes
npx jest --watch
```

### Run Tests with Verbose Output

```bash
# Show detailed test results
npx jest --verbose
```

### Skip Slow Tests

```bash
# Skip URL validation tests (which can be slow)
npx jest --testPathIgnorePatterns=urls.test.js
```

## ⚙️ Test Configuration

### `jest.config.js`

The Jest configuration file includes:

```javascript
{
  testEnvironment: 'node',           // Node.js environment
  testMatch: ['**/*.test.js'],       // Test file patterns
  coverageDirectory: 'coverage',     // Coverage output
  maxWorkers: '50%',                 // Parallel execution
  testTimeout: 30000,                // 30 second timeout
  verbose: true                      // Detailed output
}
```

### Environment Variables

```bash
# Set Node environment
export NODE_ENV=test

# Increase memory for large test suites
export NODE_OPTIONS="--max-old-space-size=4096"
```

## ✍️ Writing Tests

### Basic Test Structure

```javascript
describe('Feature Name', () => {
  // Setup before all tests
  beforeAll(async () => {
    // Load data, initialize resources
  });

  // Cleanup after all tests
  afterAll(async () => {
    // Clean up resources
  });

  // Individual test
  test('should do something', () => {
    expect(result).toBe(expected);
  });

  // Parameterized tests
  test.each(items)('should validate: %s', (item) => {
    expect(validate(item)).toBe(true);
  });
});
```

### Using Test Utilities

```javascript
const {
  readJSONFile,
  getEntryData,
  isValidDomain,
} = require('./test-utils');

test('should read entry file', async () => {
  const { name, entry } = await getEntryData('entries/a/adobe.com.json');
  expect(isValidDomain(entry.domain)).toBe(true);
});
```

### Best Practices

1. **Use Descriptive Names**: Test names should clearly describe what is being tested
2. **One Assertion Per Test**: Keep tests focused and simple
3. **Use Helpers**: Leverage `test-utils.js` for common operations
4. **Handle Async**: Always use `async/await` for asynchronous operations
5. **Mock External Calls**: Mock network requests when possible
6. **Clean Up**: Always clean up resources in `afterAll` or `afterEach`

### Example Test

```javascript
/**
 * Test: Validate entry has required fields
 */
describe('Required Fields', () => {
  test.each(entryFiles)('should have domain: %s', async (file) => {
    const { entry } = await getEntryData(file);
    
    expect(entry).toHaveProperty('domain');
    expect(typeof entry.domain).toBe('string');
    expect(entry.domain.length).toBeGreaterThan(0);
  });
});
```

## 🔄 Continuous Integration

### GitHub Actions Integration

The tests are integrated with GitHub Actions in `.github/workflows/pull_request.yml`:

```yaml
- name: Run Jest Tests
  run: npm test

- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

### Pre-commit Hooks

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
npm test -- --bail --findRelatedTests
```

## 📊 Coverage Reports

### Generate Coverage

```bash
npx jest --coverage
```

### Coverage Thresholds

Configure in `jest.config.js`:

```javascript
coverageThreshold: {
  global: {
    branches: 80,
    functions: 80,
    lines: 80,
    statements: 80
  }
}
```

## 🐛 Debugging Tests

### Run Single Test

```bash
# Run only tests matching pattern
npx jest -t "should have valid domain"
```

### Debug in VS Code

Add to `.vscode/launch.json`:

```json
{
  "type": "node",
  "request": "launch",
  "name": "Jest Debug",
  "program": "${workspaceFolder}/node_modules/.bin/jest",
  "args": ["--runInBand", "--no-cache"],
  "console": "integratedTerminal"
}
```

### Verbose Logging

```bash
# Enable debug output
DEBUG=* npx jest
```

## 📚 Additional Resources

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [AJV Schema Validator](https://ajv.js.org/)
- [Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)

## 🤝 Contributing

When adding new features:

1. Write tests first (TDD approach)
2. Ensure all tests pass
3. Maintain or improve coverage
4. Update this README if needed

## 🎯 Common Scenarios

### Before Committing

```bash
# Run all tests except slow URL checks
npm test -- --testPathIgnorePatterns=urls.test.js
```

### Before Pull Request

```bash
# Run full test suite with coverage
npm run test:coverage
```

### During Development

```bash
# Watch mode for rapid feedback
npm run test:watch
```

### Debugging a Specific Test

```bash
# Run only tests matching a pattern
npm test -- -t "should have valid domain"
```

## 🔧 Troubleshooting

### Tests Timing Out

```bash
# Increase timeout
npm test -- --testTimeout=60000
```

### Memory Issues

```bash
# Increase Node.js memory
export NODE_OPTIONS="--max-old-space-size=4096"
npm test
```

### Network Issues (URL Tests)

```bash
# Skip URL tests
npm test -- --testPathIgnorePatterns=urls.test.js
```

### Understanding Test Output

- **✓ PASS** - Test passed successfully
- **✗ FAIL** - Test failed, check error message
- **⊘ SKIP** - Test was skipped
- **⚠ WARN** - Warning (not a failure)

## 📝 License

Tests are part of the 2FA Directory project and follow the same MIT license.
