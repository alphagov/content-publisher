/* eslint-env jasmine */

describe('Gtm topic listener', function () {
  'use strict'

  beforeEach(function () {
    window.dataLayer = []
  })

  describe('search-topic events', function () {
    it('should push to the dataLayer', function () {
      document.dispatchEvent(new window.CustomEvent('search-topic', {
        bubbles: true,
        detail: {
          topicNames: ['Business and industry', 'Business regulation']
        }
      }))

      expect(window.dataLayer).toContain({
        event: 'Click',
        dataGtm: 'select-topic-from-search-results',
        dataGtmValue: 'Business and industry > Business regulation'
      })
    })
  })

  describe('remove-topic events', function () {
    it('should push to the dataLayer', function () {
      document.dispatchEvent(new window.CustomEvent('remove-topic', {
        bubbles: true,
        detail: {
          topicNames: ['Business and industry', 'Business regulation']
        }
      }))

      expect(window.dataLayer).toContain({
        event: 'Click',
        dataGtm: 'remove-topic',
        dataGtmValue: 'Business and industry > Business regulation'
      })
    })
  })
})
