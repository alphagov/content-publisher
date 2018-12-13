describe('GTM dataLayer messages for copy and paste events', function () {
  'use strict'

  var dataLayer

  beforeEach(function () {
    var rawForm = `
      <form id="testForm">
        <input id="textInput" type="text" name="copy" value="the text">
      </form>
      `
    document.body.insertAdjacentHTML('beforeend', rawForm)
    window.dataLayer = []
    new GTMCopyListener().init()
  })

  afterEach(function () {
    document.getElementById('testForm').remove()
  })

  it('should push to the dataLayer on copy', function () {
    var input = document.getElementById('textInput')
    input.select()
    if (!document.queryCommandEnabled('copy')) {
      pending('It is only possible to trigger copy in user-initiated event handler')
    }
    document.execCommand('copy')

    expect(window.dataLayer).toEqual([
      {
        'event': 'text-copied',
        'copiedText': 'the-text',
        'textLength': 8
      }
    ])
  })

  it('should push to the dataLayer on paste', function () {
    var input = document.getElementById('textInput')
    input.select()
    if (!document.queryCommandEnabled('paste')) {
      pending('It is only possible to trigger paste in user-initiated event handler')
    }
    document.execCommand('paste')

    expect(window.dataLayer).toEqual([
      { 'event': 'text-pasted' }
    ])
  })
})
