/* eslint-env jasmine */

describe('Gtm copy paste listener', function () {
  'use strict'

  var container

  describe('when all attributes are specified', function () {
    beforeEach(function () {
      container = document.createElement('div')
      container.innerHTML = '<input data-gtm-copy-paste-tracking=true data-gtm="my-input">'

      document.body.appendChild(container)
      window.dataLayer = []
    })

    afterEach(function () {
      document.body.removeChild(container)
    })

    it('should push to the dataLayer on copy/paste', function () {
      var input = container.querySelector('input')

      input.dispatchEvent(new window.Event('copy', { bubbles: true }))
      input.dispatchEvent(new window.Event('paste', { bubbles: true }))

      expect(window.dataLayer).toContain({ dataGtm: 'my-input', event: 'Copy' })
      expect(window.dataLayer).toContain({ dataGtm: 'my-input', event: 'Paste' })
    })
  })

  describe('when no data-gtm is specified', function () {
    beforeEach(function () {
      container = document.createElement('div')
      container.innerHTML = '<input data-gtm-copy-paste-tracking=true>'

      document.body.appendChild(container)
      window.dataLayer = []
    })

    afterEach(function () {
      document.body.removeChild(container)
    })

    it('should not push to the dataLayer on copy/paste', function () {
      var input = container.querySelector('input')

      input.dispatchEvent(new window.Event('copy', { bubbles: true }))
      input.dispatchEvent(new window.Event('paste', { bubbles: true }))

      expect(window.dataLayer).toEqual([])
    })
  })

  describe('when listener attribute is specified', function () {
    beforeEach(function () {
      container = document.createElement('div')
      container.innerHTML = '<input data-gtm="my-input">'

      document.body.appendChild(container)
      window.dataLayer = []
    })

    afterEach(function () {
      document.body.removeChild(container)
    })

    it('should not push to the dataLayer on copy/paste', function () {
      var input = container.querySelector('input')

      input.dispatchEvent(new window.Event('copy', { bubbles: true }))
      input.dispatchEvent(new window.Event('paste', { bubbles: true }))

      expect(window.dataLayer).toEqual([])
    })
  })
})
