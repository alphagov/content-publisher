//= require vendor/accessible-autocomplete/dist/accessible-autocomplete.min.js

var $autocompletes = document.querySelectorAll('[data-module="autocomplete"]')
if ($autocompletes) {
  $autocompletes.forEach(function ($el) {
    var customAttributes = {}
    if ($el.attributes['data-contextual-guidance']) {
      customAttributes = {
        'data-contextual-guidance': $el.attributes['data-contextual-guidance'].value
      }
    }

    // disabled eslint because we can not control the name of the constructor (expected to be EnhanceSelectElement)
    new window.accessibleAutocomplete.enhanceSelectElement({ // eslint-disable-line no-new, new-cap
      selectElement: $el,
      minLength: 3,
      showNoOptionsFound: false,
      showAllValues: true,
      customAttributes: customAttributes
    })
  })
}
