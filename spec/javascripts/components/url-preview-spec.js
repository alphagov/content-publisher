/* global describe beforeEach afterEach it expect */
/* global UrlPreview */
var $ = window.jQuery

describe('URL preview component', function () {
  'use strict'

  var form
  var element

  beforeEach(function () {
    form = $(`
      <form data-module="edit-document-form" data-url-preview-path="/documents/df702388-64d3-471e-bd24-5064ada7505e:en/generate-path">
        <textarea name="document[title]" class="gem-c-textarea govuk-textarea" data-url-preview="input"></textarea>
      </form>
    `)
    element = $(`
      <div class="app-c-url-preview" data-module="url-preview">
        <div class="gem-c-inset-text govuk-inset-text">
          <p class="app-c-url-preview__title">Page address</p>
          <p class="app-c-url-preview__default-message js-url-preview-default-message app-c-url-preview__default-message--hidden">You haven't entered a title yet</p>
          <p class="app-c-url-preview__error-message app-c-url-preview__error-message--hidden js-url-preview-error-message">Unable to generate URL</p>
          <p class="app-c-url-preview__url js-url-preview-url">
            <span>http://www.gov.uk</span><span class="app-c-url-preview__path js-url-preview-path">/news/</span>
          </p>
        </div>
      </div>
    `)
    $(document.body).append(form)
    $(document.body).append(element)
    new UrlPreview(element[0]).init()
  })

  afterEach(function () {
    form.remove()
    form = undefined
    element.remove()
    element = undefined
  })

  it('should only display the default message if input is empty', function () {
    // Interact with input and leave empty
    $('[data-url-preview="input"]').focus().blur()

    var defaultMessage = $('.js-url-preview-default-message')
    expect(defaultMessage.hasClass('app-c-url-preview__default-message--hidden')).toEqual(false)

    var previewURL = $('.js-url-preview-url')
    expect(previewURL.hasClass('app-c-url-preview__url--hidden')).toEqual(true)

    var errorMessage = $('.js-url-preview-error-message')
    expect(errorMessage.hasClass('app-c-url-preview__error-message--hidden')).toEqual(true)
  })

  it('should only display the preview URL if input has value', function () {
    // Interact with input and set value
    $('[data-url-preview="input"]').focus().val('My title').blur()

    var defaultMessage = $('.js-url-preview-default-message')
    expect(defaultMessage.hasClass('app-c-url-preview__default-message--hidden')).toEqual(true)

    var previewURL = $('.js-url-preview-url')
    expect(previewURL.hasClass('app-c-url-preview__url--hidden')).toEqual(false)

    var errorMessage = $('.js-url-preview-error-message')
    expect(errorMessage.hasClass('app-c-url-preview__error-message--hidden')).toEqual(true)
  })
})
