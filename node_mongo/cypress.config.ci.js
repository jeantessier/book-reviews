const { defineConfig } = require('cypress')

module.exports = defineConfig({
  registerUrl: '/api/register',
  loginUrl: '/api/login',
  bookUrl: '/api/book',
  userUrl: '/api/user',
  reviewUrl: '/api/review',
  e2e: {
    // We've imported your old cypress plugins here.
    // You may want to clean this up later by importing these.
    setupNodeEvents(on, config) {
      return require('./cypress/plugins/index.js')(on, config)
    },
    baseUrl: 'http://localhost:3000',
  },
})
