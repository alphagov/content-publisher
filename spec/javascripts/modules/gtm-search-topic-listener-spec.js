/* eslint-env jasmine */

describe('Gtm search topic listener', function () {
  'use strict'

  beforeEach(function () {
    window.dataLayer = []
  })

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
