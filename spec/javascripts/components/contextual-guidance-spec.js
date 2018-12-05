/* global describe beforeEach afterEach it expect */
/* global ContextualGuidance */

describe('Contextual guidance component', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<input id="document-title" type="text" class="gem-c-input govuk-input" data-contextual-guidance="document-title-guidance"></textarea>' +

      '<div id="document-title-guidance" class="app-c-contextual-guidance-wrapper">' +
        '<div class="app-c-contextual-guidance">' +
        '<h2 class="govuk-heading-s">Title</h2>' +
        'The title should be unique and specific. It must make clear what the content offers users. Use the words your users do to help them find this. Avoid wordplay or teases.' +
        '</div>' +
      '</div>' +

      '<textarea id="document-summary" class="gem-c-textarea govuk-textarea" data-contextual-guidance="document-summary-guidance"></textarea>' +

      '<div id="document-summary-guidance" class="app-c-contextual-guidance-wrapper">' +
        '<div class="app-c-contextual-guidance">' +
        '<h2 class="govuk-heading-s">Summary</h2>' +
        'The summary should explain the main point of the story. It is the first line of the story so don’t repeat it in the body and end with a full stop.' +
        '</div>' +
      '</div>'

    document.body.appendChild(container)
    new ContextualGuidance().init(document)
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should show associated guidance on focus', function () {
    var title = document.querySelector('#document-title')
    var titleGuidance = document.querySelector('#document-title-guidance')

    var summary = document.querySelector('#document-summary')
    var summaryGuidance = document.querySelector('#document-summary-guidance')

    title.dispatchEvent(new Event('focus'))

    expect(titleGuidance.style.display).toEqual('block')
    expect(summaryGuidance.style.display).toEqual('none')
  })

  it('should hide associated guidance when another element is focused', function () {
    var title = document.querySelector('#document-title')
    var titleGuidance = document.querySelector('#document-title-guidance')

    var summary = document.querySelector('#document-summary')
    var summaryGuidance = document.querySelector('#document-summary-guidance')

    title.dispatchEvent(new Event('focus'))
    summary.dispatchEvent(new Event('focus'))

    expect(titleGuidance.style.display).toEqual('none')
    expect(summaryGuidance.style.display).toEqual('block')
  })
})
