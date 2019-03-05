/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('URL preview component', function () {
  'use strict'

  var container

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
    new GOVUK.Modules.UrlPreview().start($(element))
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should only display the default message if input is empty', function () {
    // Interact with input and leave empty
    var input = document.querySelector('[data-url-preview="input"]')
    input.dispatchEvent(new window.Event('blur'))

    var defaultMessage = document.querySelector('.js-url-preview-default-message')
    expect(defaultMessage).toBeVisible()

    var previewURL = document.querySelector('.js-url-preview-url')
    expect(previewURL).toBeHidden()

    var errorMessage = document.querySelector('.js-url-preview-error-message')
    expect(errorMessage).toBeHidden()
  })

  it('should only display the preview URL if input has value', function () {
    // Interact with input and set value
    var input = document.querySelector('[data-url-preview="input"]')
    input.value = 'My title'
    input.dispatchEvent(new window.Event('blur'))

    var defaultMessage = document.querySelector('.js-url-preview-default-message')
    expect(defaultMessage).toBeHidden()

    var previewURL = document.querySelector('.js-url-preview-url')
    expect(previewURL).toBeVisible()

    var errorMessage = document.querySelector('.js-url-preview-error-message')
    expect(errorMessage).toBeHidden()
  })
})
