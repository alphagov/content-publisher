/* global describe beforeEach afterEach it expect */
/* global GTMFormListener */

describe('GTM form listener', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<form data-gtm="new-document" onsubmit="return false;">' +
        '<input type="radio" name="supertype" id="radio-news" value="news">' +
        '<input type="radio" name="supertype" id="radio-guidance" value="guidance">' +
        '<input type="checkbox" name="caprinae" id="checkbox-goat" value="goat">' +
        '<input type="checkbox" name="caprinae" id="checkbox-ibex" value="ibex">' +
      '</form>'

    document.body.appendChild(container)
    window.dataLayer = []
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should append the corrent message on submit for radios', function () {
    document.getElementById('radio-guidance').click()
    var submitFormEvent = new window.Event('submit', { 'bubbles': true })
    document.querySelector('form[data-gtm]').dispatchEvent(submitFormEvent)
    expect(window.dataLayer).toEqual([{'new-document': { supertype: 'guidance' }}])
  })

  it('should append the corrent message on submit for checkboxes', function () {
    document.getElementById('checkbox-ibex').click()
    document.getElementById('checkbox-goat').click()
    var submitFormEvent = new window.Event('submit', { 'bubbles': true })
    document.querySelector('form[data-gtm]').dispatchEvent(submitFormEvent)

    expect(window.dataLayer).toEqual([
      {'new-document': { caprinae: 'goat' }},
      {'new-document': { caprinae: 'ibex' }}
    ])
  })
})
