/* global describe beforeEach afterEach it expect */
/* global ContextualGuidance */
var $ = window.jQuery

describe('Contextual guidance component', function () {
  'use strict'

  var elements

  beforeEach(function () {
    elements = $(`
      <input id="document-title" type="text" class="gem-c-input govuk-input" data-contextual-guidance="document-title-guidance"></textarea>

      <div id="document-title-guidance" class="app-c-contextual-guidance-wrapper">
        <div class="app-c-contextual-guidance">
        <h2 class="govuk-heading-s">Title</h2>
        The title should be unique and specific. It must make clear what the content offers users. Use the words your users do to help them find this. Avoid wordplay or teases.
        </div>
      </div>

      <textarea id="document-summary" class="gem-c-textarea govuk-textarea" data-contextual-guidance="document-summary-guidance"></textarea>

      <div id="document-summary-guidance" class="app-c-contextual-guidance-wrapper">
        <div class="app-c-contextual-guidance">
        <h2 class="govuk-heading-s">Summary</h2>
        The summary should explain the main point of the story. It is the first line of the story so don’t repeat it in the body and end with a full stop.
        </div>
      </div>
    `)
    $(document.body).append(elements)
    new ContextualGuidance().init(document)
  })

  afterEach(function () {
    elements.remove()
    elements = undefined
  })

  it('should hide all guidance', function () {
    expect($('.app-c-contextual-guidance-wrapper')).toHaveClass('govuk-visually-hidden')
  })

  it('should show associated guidance on focus', function () {
    $('#document-title').focus()
    expect($('#document-title-guidance')).not.toHaveClass('govuk-visually-hidden')
    expect($('#document-summary-guidance')).toHaveClass('govuk-visually-hidden')
  })

  it('should hide associated guidance when another element is focused', function () {
    $('#document-summary').focus()
    expect($('#document-title-guidance')).toHaveClass('govuk-visually-hidden')
    expect($('#document-summary-guidance')).not.toHaveClass('govuk-visually-hidden')
  })
})
