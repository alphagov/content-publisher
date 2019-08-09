/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('Contact preview component', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<select name="contact_id" id="contact-id-select" class="govuk-select">' +
        '<option value=""></option>' +
        '<option value="63e37a39-aa4a-417a-9844-5aa308c7bf0d">Government Legal Department</option>' +
      '</select>' +

      '<div class="app-c-contact-preview app-c-contact-preview--hidden" data-module="contact-preview" data-for="contact-id-select" data-contact-snippet-template="[Contact: #]" data-govspeak-path="/">' +
        '<div class="gem-c-inset-text govuk-inset-text">' +
          '<p class="app-c-contact-preview__error-message app-c-contact-preview__error-message--hidden js-contact-preview-error-message">Unable to generate preview</p>' +
          '<div class="app-c-contact-preview__html js-contact-preview-html"></div>' +
        '</div>' +
      '</div>'

    document.body.appendChild(container)
    var element = document.querySelector('[data-module="contact-preview"]')
    new GOVUK.Modules.ContactPreview().start($(element))
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should display the contact preview if an option is selected', async function () {
    var contactPreview = '<div class="gem-c-govspeak">' +
      '<div class="contact">' +
        '<div class="content">' +
          '<h3>Government Legal Department</h3>' +
          '<div class="vcard contact-inner">' +
            '<p class="adr">Croydon, CR90 9QU</p>' +
          '</div>' +
          '<p class="comments">Find contact details and the opening hours.</p>' +
        '</div>' +
      '</div>' +
    '</div>'

    spyOn(GOVUK.Modules.ContactPreview.prototype, 'fetchContactPreview').and.returnValue(Promise.resolve(contactPreview))

    var select = document.querySelector('#contact-id-select')
    select.options[1].selected = true
    await select.dispatchEvent(new window.Event('change'))

    expect(GOVUK.Modules.ContactPreview.prototype.fetchContactPreview).toHaveBeenCalledWith(select.value)

    var element = document.querySelector('[data-module="contact-preview"]')
    expect(element).toBeVisible()

    var previewContainer = document.querySelector('.js-contact-preview-html')
    expect(previewContainer).toBeVisible()
    expect(previewContainer.innerHTML).toEqual(contactPreview)

    var errorMessage = document.querySelector('.js-contact-preview-error-message')
    expect(errorMessage).toBeHidden()
  })

  it('should remove the preview container if no option is selected', async function () {
    spyOn(GOVUK.Modules.ContactPreview.prototype, 'hideContactPreview').and.callThrough()

    var select = document.querySelector('#contact-id-select')
    select.options[1].selected = true // select first item
    select.selectedIndex = -1 // reset option selection
    await select.dispatchEvent(new window.Event('change'))

    expect(GOVUK.Modules.ContactPreview.prototype.hideContactPreview).toHaveBeenCalled()

    var element = document.querySelector('[data-module="contact-preview"]')
    expect(element).toBeHidden()
  })
})
