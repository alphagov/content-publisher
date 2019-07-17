/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('Page preview component', function () {
  'use strict'

  var container
  var pagePreview
  var draftUrl = 'https://draft-origin.publishing.service.gov.uk'

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<div class="app-c-preview" data-module="page-preview"  data-iframe-origin-url="' + draftUrl + '">' +
        '<iframe class="app-c-preview__mobile-iframe" src="' + draftUrl + '/government/news/foreign-secretary-heads-to-brussels-to-discuss-iran" title="Preview of the page on mobile"></iframe>' +
        '<iframe class="app-c-preview__desktop-iframe" src="' + draftUrl + '/government/news/foreign-secretary-heads-to-brussels-to-discuss-iran" title="Preview of the page on mobile"></iframe>' +
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

    pagePreview.sendMessage(mobileIframe, {'hideCookieBanner': 'true'}, draftUrl)

    expect(mobileIframe.contentWindow.postMessage).toHaveBeenCalled()
  })
})
