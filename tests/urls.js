#!/usr/bin/env node

const fs = require('fs');
const { chromium } = require('playwright');
const core = require('@actions/core');
require('dotenv').config(); // Load environment variables from .env file

// Function to check if a URL is reachable using Playwright
async function checkUrl(url) {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  try {
    const response = await page.goto(url, { waitUntil: 'networkidle' });
    const status = response.status();
    if (status >= 200 && status < 400) {
      core.info(`Reachable: ${url}`);
      await browser.close();
      return { url, reachable: true };
    }
  } catch (err) {
    core.error(`Not reachable: ${url}`);
  }
  await browser.close();
  return { url, reachable: false };
}

// Main function to read URLs from a file and check their reachability
async function main() {
  const filePath = process.argv.slice(2); // Get the file path from command-line arguments
  if (!filePath) {
    core.error('Please provide a file path');
    process.exit(1);
  }

  if (!fs.existsSync(filePath)) {
    core.error('File does not exist');
    process.exit(1);
  }

  const urls = fs.readFileSync(filePath, 'utf-8').split('\n').filter(Boolean);
  const results = await Promise.all(urls.map(url => checkUrl(url)));

  // Log results
  const reachableUrls = results.filter(result => result.reachable).map(result => result.url);
  const unreachableUrls = results.filter(result => !result.reachable).map(result => result.url);

  core.info(`Reachable URLs (${reachableUrls.length}):`);
  reachableUrls.forEach(url => core.info(url));

  core.error(`Unreachable URLs (${unreachableUrls.length}):`);
  unreachableUrls.forEach(url => core.error(url));

  // Exit with status code 1 if there are unreachable URLs
  process.exit(unreachableUrls.length > 0 ? 1 : 0);
}

// Execute the main function and catch any errors
main().catch(err => {
  core.error('Error in main execution:', err);
  process.exit(1);
});
