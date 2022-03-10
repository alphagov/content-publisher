/* global fetchMock */

// Depends upon fetch-mock@9.11.0/es5/client-bundle.js
// which is imported by spec/support/jasmine-browser.json

// Reset fetch mocks before each test
beforeEach(fetchMock.reset)
