/* global describe beforeEach afterEach it expect */
/* global GTMCopyListener Event */

describe('GTM dataLayer messages for copy and paste events', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML = '<input id="textInput" type="text" name="copy" value="the text">'
    container.dataset.gtmCopyPasteTracking = 'copy-input-value'
    document.body.appendChild(container)
    window.dataLayer = []
    new GTMCopyListener(container).init()
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should push to the dataLayer on copy', function () {
    var input = document.getElementById('textInput')
    input.select()
    container.dispatchEvent(new Event('copy'))

    expect(window.dataLayer).toContain(
      {
        'event': 'text-copied',
        'element': 'copy-input-value'
      }
    )
  })

  it('should push to the dataLayer on paste', function () {
    var input = document.getElementById('textInput')
    input.select()
    container.dispatchEvent(new Event('paste'))

    expect(window.dataLayer).toContain(
      {
        'event': 'text-pasted',
        'element': 'copy-input-value'
      }
    )
  })
})
