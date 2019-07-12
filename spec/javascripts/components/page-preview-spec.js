/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('Page preview component', function () {
  'use strict'

  var container
  var pagePreview

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<div class="app-c-preview" data-module="page-preview">' +
        '<iframe class="app-c-preview__mobile-iframe" src="http://localhost:3221/component-guide/cookie_banner/default/preview" title="Preview of the page on mobile"></iframe>' +
        '<iframe class="app-c-preview__desktop-iframe" src="http://localhost:3221/component-guide/cookie_banner/default/preview" title="Preview of the page on desktop or tablet"></iframe>' +
      '</div>'

    document.body.appendChild(container)
    var element = document.querySelector('[data-module="page-preview"]')
    pagePreview = new GOVUK.Modules.PagePreview()
    pagePreview.start($(element))
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should send a message to the mobile iframe\'s source document to hide the cookie banner', function () {
    var mobileIframe = container.querySelector('.app-c-preview__mobile-iframe')
    spyOn(mobileIframe.contentWindow, 'postMessage')

    pagePreview.sendMessage(mobileIframe, {'hideCookieBanner': 'true'})

    expect(mobileIframe.contentWindow.postMessage).toHaveBeenCalled()
  })
})
