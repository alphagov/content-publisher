/* global describe beforeEach afterEach it expect */
/* global GtmCopyListener */

describe('Gtm copy paste listener', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML = '<input data-gtm-copy-paste-tracking="my-input">'

    document.body.appendChild(container)
    window.dataLayer = []
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should push to the dataLayer on copy', function () {
    var input = container.querySelector('input')
    input.dispatchEvent(new window.Event('copy', { bubbles: true }))

    expect(window.dataLayer).toContain(
      {
        'event': 'text-copied',
        'element': 'my-input'
      }
    )
  })

  it('should push to the dataLayer on paste', function () {
    var input = container.querySelector('input')
    input.dispatchEvent(new window.Event('paste', { bubbles: true }))

    expect(window.dataLayer).toContain(
      {
        'event': 'text-pasted',
        'element': 'my-input'
      }
    )
  })
})
