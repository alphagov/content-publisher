//= require vendor/accessible-autocomplete/dist/accessible-autocomplete.min.js

var $autocompletes = document.querySelectorAll('[data-module="autocomplete"]')
if ($autocompletes) {
  $autocompletes.forEach(function ($el) {
    var customAttributes = {}
    var $select = $el.querySelector('select')
    if ($select.attributes['data-contextual-guidance']) {
      customAttributes = {
        'data-contextual-guidance': $select.attributes['data-contextual-guidance'].value
      }
    }

    // disabled eslint because we can not control the name of the constructor (expected to be EnhanceSelectElement)
    new window.accessibleAutocomplete.enhanceSelectElement({ // eslint-disable-line no-new, new-cap
      selectElement: $select,
      minLength: 3,
      showNoOptionsFound: true,
      customAttributes: customAttributes
    })
  })
}

var $customTemplateAutocomplete = document.querySelector('[data-module="autocomplete-custom-template"]')
if ($customTemplateAutocomplete) {
  // Read options and associated data attributes and feed that as results for inputValueTemplate
  var $select = $customTemplateAutocomplete.querySelector('select')
  var $options = $select.querySelectorAll('option')

  // Create wrapper to inject the autocomplete element
  $customTemplateAutocomplete.insertAdjacentHTML('beforeend', '<div class="autocomplete__wrapper"></div>')

  // Remove select element from DOM
  $select.remove()

  new window.accessibleAutocomplete({ // eslint-disable-line no-new, new-cap
    element: $customTemplateAutocomplete.querySelector('.autocomplete__wrapper'),
    id: $select.id,
    source: function (query, syncResults) {
      var results = []
      $options.forEach(function ($el) {
        results.push({value: $el.textContent, hint: $el.dataset.hint || ''})
      })

      syncResults(query
        ? results.filter(function (result) {
          var valueContains = result.value.toLowerCase().indexOf(query.toLowerCase()) !== -1
          var hintContains = result.hint.toLowerCase().indexOf(query.toLowerCase()) !== -1
          return valueContains || hintContains
        })
        : []
      )
    },
    minLength: 3,
    autoselect: true,
    showNoOptionsFound: true,
    templates: {
      inputValue: function (result) {
        return result && result.value
      },
      suggestion: function (result) {
        return result && result.value + '<span class="autocomplete__option-hint">' + result.hint + '</span>'
      }
    }
  })
}
