/* global describe beforeEach afterEach it expect */
/* global GTMFormListener Event */

describe('GTM dataLayer messages for radio button submissions', function () {
  'use strict'

  var dataLayer
  var submitFormEvent = new Event('submit', {'bubbles': true, 'cancelable': true})
  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<form id="testForm" data-gtm="new-document" onsubmit="return false;">' +
        '<input type="radio" name="supertype" id="radio-news" value="news">' +
        '<input type="radio" name="supertype" id="radio-guidance" value="guidance">' +
        '<input type="checkbox" name="caprinae" id="checkbox-goat" value="goat">' +
        '<input type="checkbox" name="caprinae" id="checkbox-sheep" value="sheep">' +
        '<input type="checkbox" name="caprinae" id="checkbox-ibex" value="ibex">' +
      '</form>'
    document.body.appendChild(container)
    dataLayer = []
    GTMFormListener.init(dataLayer)
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should append the corrent message on submit for radios', function () {
    document.getElementById('radio-guidance').click()
    document.getElementById('testForm').dispatchEvent(submitFormEvent)

    expect(dataLayer).toEqual([{'new-document': { supertype: 'guidance' }}])
  })

  it('should append the corrent message on submit for checkboxes', function () {
    document.getElementById('checkbox-sheep').click()
    document.getElementById('checkbox-goat').click()
    document.getElementById('testForm').dispatchEvent(submitFormEvent)

    expect(dataLayer).toEqual([
      {'new-document': { caprinae: 'goat' }},
      {'new-document': { caprinae: 'sheep' }}
    ])
  })
})
