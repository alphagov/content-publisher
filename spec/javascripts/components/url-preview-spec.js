/* eslint-env jasmine, jquery */
/* global GOVUK, fetchMock */

describe('URL preview component', function () {
  'use strict'

  var container, urlPreview

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<form data-module="edit-document-form" data-url-preview-path="/documents/df702388-64d3-471e-bd24-5064ada7505e:en/generate-path">' +
        '<textarea name="document[title]" class="gem-c-textarea govuk-textarea" data-url-preview="input"></textarea>' +
      '</form>' +

      '<div class="app-c-url-preview" data-module="url-preview">' +
        '<div class="gem-c-inset-text govuk-inset-text">' +
          '<p class="app-c-url-preview__title">Page address</p>' +
          '<p class="app-c-url-preview__default-message js-url-preview-default-message app-c-url-preview__default-message--hidden">You haven\'t entered a title yet</p>' +
          '<p class="app-c-url-preview__error-message app-c-url-preview__error-message--hidden js-url-preview-error-message">Unable to generate URL</p>' +
          '<p class="app-c-url-preview__url js-url-preview-url">' +
            '<span>http://www.gov.uk</span><span class="app-c-url-preview__path js-url-preview-path">/news/</span>' +
          '</p>' +
        '</div>' +
      '</div>'

    document.body.appendChild(container)
    var element = document.querySelector('[data-module="url-preview"]')
    urlPreview = new GOVUK.Modules.UrlPreview()
    urlPreview.start($(element))
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('displays a default message when the input is empty', function () {
    urlPreview.input.value = ''
    urlPreview.input.dispatchEvent(new window.Event('blur'))

    expect(urlPreview.defaultMessage).toBeVisible()
    expect(urlPreview.urlPreview).toBeHidden()
    expect(urlPreview.errorMessage).toBeHidden()
  })

  it('displays the preview URL when a user inputs a value and a slug is generated', function (done) {
    fetchMock.get(/generate-path\?title=My\+title/, 'my-title')

    urlPreview.input.value = 'My title'
    urlPreview.input.dispatchEvent(new window.Event('blur'))

    fetchMock.flush(true).then(function () {
      expect(urlPreview.defaultMessage).toBeHidden()
      expect(urlPreview.urlPreview).toBeVisible()
      expect(urlPreview.urlPreview).toContainText('my-title')
      expect(urlPreview.errorMessage).toBeHidden()
      done()
    })
  })

  it('displays an error when the request to generate a path fails', function (done) {
    fetchMock.get(/generate-path\?title=My\+title/, 500)

    urlPreview.input.value = 'My title'
    urlPreview.input.dispatchEvent(new window.Event('blur'))

    fetchMock.flush(true).then(function () {
      expect(urlPreview.defaultMessage).toBeHidden()
      expect(urlPreview.urlPreview).toBeHidden()
      expect(urlPreview.errorMessage).toBeVisible()
      done()
    })
  })

  it('displays an error if the request takes longer than 5 seconds', function (done) {
    jasmine.clock().withMock(function () {
      fetchMock.get(/generate-path\?title=My\+title/, 'my-title', { delay: 10000 })

      urlPreview.input.value = 'My title'
      urlPreview.input.dispatchEvent(new window.Event('blur'))

      jasmine.clock().tick(5001)

      fetchMock.flush(true).then(function () {
        expect(urlPreview.defaultMessage).toBeHidden()
        expect(urlPreview.urlPreview).toBeHidden()
        expect(urlPreview.errorMessage).toBeVisible()
        done()
      })
    })
  })
})
