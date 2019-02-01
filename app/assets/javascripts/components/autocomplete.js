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

var $autocompleteWithHintOnOptions = document.querySelector('[data-module="autocomplete-with-hint-on-options"]')
if ($autocompleteWithHintOnOptions) {
  // Read options and associated data attributes and feed that as results for inputValueTemplate
  var $select = $autocompleteWithHintOnOptions.querySelector('select')
  var $options = $select.querySelectorAll('option')

  new window.accessibleAutocomplete({ // eslint-disable-line no-new, new-cap
    element: $autocompleteWithHintOnOptions,
    id: $select.id,
    source: function (query, syncResults) {
      var results = []
      $options.forEach(function ($el) {
        results.push({text: $el.textContent, hint: $el.dataset.hint || '', value: $el.value})
      })
      syncResults(query
        ? results.filter(function (result) {
          var valueContains = result.text.toLowerCase().indexOf(query.toLowerCase()) !== -1
          var hintContains = result.hint.toLowerCase().indexOf(query.toLowerCase()) !== -1
          return valueContains || hintContains
        }) : []
      )
    },
    minLength: 3,
    autoselect: true,
    showNoOptionsFound: true,
    templates: {
      inputValue: function (result) {
        return result && result.text
      },
      suggestion: function (result) {
        return result && result.text + '<span class="autocomplete__option-hint">' + result.hint + '</span>'
      }
    },
    onConfirm: function (result) {
      var value = result && result.value
      var options = [].filter.call($select.options, function (option) {
        return option.value === value
      })

      if (options.length) {
        options[0].selected = true
      }
    }
  })

  $select.style.display = 'none'
  $select.id = $select.id + '-select'
}
