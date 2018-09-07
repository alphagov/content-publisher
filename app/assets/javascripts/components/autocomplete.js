//= require vendor/accessible-autocomplete/dist/accessible-autocomplete.min.js

/* eslint-disable */
// disabled eslint because we can not control the name of the constructor (expected to be EnhanceSelectElement)
var $autocompletes = document.querySelectorAll('[data-module="autocomplete"]')
if ($autocompletes) {
  $autocompletes.forEach(function ($el) {
    new accessibleAutocomplete.enhanceSelectElement({
      selectElement: $el,
      showAllValues: true,
      showNoOptionsFound: false
    })
  })
}

var $multiselects = document.querySelectorAll('[data-module="autocomplete-multiselect"]')
if ($multiselects) {
  $multiselects.forEach(function ($el) {
    new accessibleAutocomplete.enhanceSelectElement({
      selectElement: $el,
      showAllValues: true,
      showNoOptionsFound: false,
      multiple: true
    })
  })
}
/* eslint-enable */
