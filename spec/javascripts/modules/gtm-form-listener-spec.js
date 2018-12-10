describe('GTM dataLayer messages for radio button submissions', function () {
  'use strict'

  var dataLayer

  beforeEach(function () {
    var rawForm = `
      <form id="myForm" data-gtm="new-document" onsubmit="return false;">
        <input type="radio" name="supertype" id="radio-news" value="news">
        <input type="radio" name="supertype" id="radio-guidance" value="guidance">
      </form>
      `
    document.body.insertAdjacentHTML('beforeend', rawForm)
    dataLayer = []
    GTMFormListener.init(dataLayer)
  })

  afterEach(function () {
    document.getElementById('myForm').remove()
  })

  it('should append the corrent message on submit', function () {
    document.getElementById('radio-guidance').click()
    var submitEvent = new Event('submit', {'bubbles': true, 'cancelable': true})
    document.getElementById('myForm').dispatchEvent(submitEvent)

    expect(dataLayer).toEqual([{'new-document': { supertype: 'guidance' }}])
  })
})
