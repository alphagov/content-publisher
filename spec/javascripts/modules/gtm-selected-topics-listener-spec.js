/* eslint-env jasmine */

describe('GTM selected topics listener', function () {
  'use strict'

  var form
  var millerColumnsSelected

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-gtm-selected-topics', '')
    form.addEventListener('submit', function (e) {
      e.preventDefault()
    })

    millerColumnsSelected = document.createElement('miller-columns-selected')
    form.appendChild(millerColumnsSelected)

    document.body.appendChild(form)
    window.dataLayer = []
  })

  afterEach(function () {
    document.body.removeChild(form)
  })

  it('updates the data layer with each of the selected topics', function () {
    millerColumnsSelected.selectedTopicNames = function () {
      return [
        ['Parent of A', 'A'],
        ['Grandparent of B', 'Parent of B', 'B']
      ]
    }

    form.dispatchEvent(new window.Event('submit', { bubbles: true }))

    expect(window.dataLayer).toEqual([
      {
        event: 'topic-selection',
        value: 'Parent of A > A'
      },
      {
        event: 'topic-selection',
        value: 'Grandparent of B > Parent of B > B'
      }
    ])
  })
})
