describe('Gtm reorder listener', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML = '<button type="button">Move</button>'

    document.body.appendChild(container)
    window.dataLayer = []
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  describe('reorder-move events', function () {
    it('should push to the dataLayer', function () {
      var button = container.querySelector('button')
      button.dispatchEvent(new window.CustomEvent('reorder-move-up', { bubbles: true }))
      button.dispatchEvent(new window.CustomEvent('reorder-move-down', { bubbles: true }))

      expect(window.dataLayer).toContain({ event: 'Click', dataGtm: 'reorder-move-up' })
      expect(window.dataLayer).toContain({ event: 'Click', dataGtm: 'reorder-move-down' })
    })
  })

  describe('reorder-drag events', function () {
    it('should push to the dataLayer', function () {
      container.dispatchEvent(new window.CustomEvent('reorder-drag', { bubbles: true }))

      expect(window.dataLayer).toContain({ event: 'Drag', dataGtm: 'reorder-drag' })
    })
  })
})
