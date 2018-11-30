//= require vendor/accessible-autocomplete/dist/accessible-autocomplete.min.js

/* eslint-disable */
// disabled eslint because we can not control the name of the constructor (expected to be EnhanceSelectElement)
var $autocompletes = document.querySelectorAll('[data-module="autocomplete"]')
if ($autocompletes) {
  $autocompletes.forEach(function ($el) {
    var customAttributes = {};
    if ( $el.attributes['data-contextual-guidance'] ) {
      customAttributes = {
        "data-contextual-guidance": $el.attributes['data-contextual-guidance'].value
      };
    }

    new accessibleAutocomplete.enhanceSelectElement({
      selectElement: $el,
      minLength: 3,
      defaultValue: '',
      customAttributes: customAttributes
    })
  })
}

var $multiselects = document.querySelectorAll('[data-module="autocomplete-multiselect"]')
if ($multiselects) {
  $multiselects.forEach(function ($el) {
    var customAttributes = {};
    if ( $el.attributes['data-contextual-guidance'] ) {
      customAttributes = {
        "data-contextual-guidance": $el.attributes['data-contextual-guidance'].value
      };
    }

    new accessibleAutocomplete.enhanceSelectElement({
      selectElement: $el,
      minLength: 3,
      showNoOptionsFound: false,
      multiple: true,
      customAttributes: customAttributes
    })
  })
}

var $customTemplateAutocomplete = document.querySelector('[data-module="autocomplete-custom-template"]')
if ($customTemplateAutocomplete) {

  new accessibleAutocomplete.enhanceSelectElement({
    selectElement: $customTemplateAutocomplete,
    minLength: 3,
    showNoOptionsFound: false,
    autoselect: false,
    defaultValue: '',
    templates: {
      inputValue: function (result) {
        if (result) {
          return result.split(' - ')[0]
        }
      },
      suggestion: function (result) {
        if (result) {
          var resultItems = result.split(' - ')
          var elem = document.createElement('span')
          elem.textContent = resultItems[0]
          if (resultItems[1]) {
            var hintContainer = document.createElement('span')
            hintContainer.className = 'autocomplete__option-hint'
            hintContainer.textContent = resultItems[1]
            elem.appendChild(hintContainer)
          }
          return elem.innerHTML
        }
      }
    }
  })
}
/* eslint-enable */
