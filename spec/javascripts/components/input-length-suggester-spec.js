/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('Input length suggester component', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<textarea name="document[title]" class="gem-c-textarea govuk-textarea" id="document_title" ' +
        'rows="2" maxlength="300" data-url-preview="input">' +
      '</textarea>' +

      '<span class="govuk-hint app-c-input-length-suggester app-c-input-length-suggester__hidden" ' +
        'data-module="input-length-suggester" data-for="document_title" data-show-from="55" ' +
        'data-message="Title should be under 65 characters. Current length: {count}" aria-live="polite">' +
          'Title should be under 65 characters. Current length: 4' +
      '</span>'

    document.body.appendChild(container)
    var element = document.querySelector('[data-module="input-length-suggester"]')
    new GOVUK.Modules.InputLengthSuggester().start($(element))
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('is hidden when the component is initialised', function () {
    var suggester = document.querySelector('[data-module="input-length-suggester"]')
    expect(suggester).toHaveClass('app-c-input-length-suggester__hidden')
  })

  it('is visible when the input grows too long', function () {
    var input = document.querySelector('#document_title')
    input.value = 'a'.repeat(55)
    input.dispatchEvent(new window.Event('change'))

    var suggester = document.querySelector('[data-module="input-length-suggester"]')
    expect(suggester).not.toHaveClass('app-c-input-length-suggester__hidden')
  })

  it('is hidden when the input gets smaller again', function () {
    var input = document.querySelector('#document_title')
    input.value = 'a'.repeat(55)
    input.dispatchEvent(new window.Event('keyup'))

    var suggester = document.querySelector('[data-module="input-length-suggester"]')
    expect(suggester).not.toHaveClass('app-c-input-length-suggester__hidden')

    input.value = 'a'.repeat(54)
    input.dispatchEvent(new window.Event('keydown'))
    expect(suggester).toHaveClass('app-c-input-length-suggester__hidden')
  })

  it('shows a message when the input grows too long', function () {
    var input = document.querySelector('#document_title')
    input.value = 'a'.repeat(55)
    input.dispatchEvent(new window.Event('change'))

    var suggester = document.querySelector('[data-module="input-length-suggester"]')
    expect(suggester.innerHTML).toEqual('Title should be under 65 characters. Current length: 55')
  })
})
