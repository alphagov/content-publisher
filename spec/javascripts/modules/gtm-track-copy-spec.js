/* global describe beforeEach afterEach it expect */
/* global GTMCopyListener Event */

describe('GTM dataLayer messages for copy and paste events', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<form id="testForm">' +
        '<input id="textInput" type="text" name="copy" value="the text">' +
      '</form>'
    document.body.appendChild(container)
    window.dataLayer = []
    new GTMCopyListener().init()
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should push to the dataLayer on copy', function () {
    var input = document.getElementById('textInput')
    input.select()
    if (!document.queryCommandEnabled('copy')) {
      document.dispatchEvent(new Event('copy'))
    }

    document.execCommand('copy')

    expect(window.dataLayer).toContain(
      {
        'event': 'text-copied'
      }
    )
  })

  it('should push to the dataLayer on paste', function () {
    var input = document.getElementById('textInput')
    input.select()
    if (!document.queryCommandEnabled('paste')) {
      document.dispatchEvent(new Event('paste'))
    }

    document.execCommand('paste')

    expect(window.dataLayer).toContain(
      {
        'event': 'text-pasted'
      }
    )
  })
})
