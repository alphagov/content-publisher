//= require vendor/accessible-autocomplete/dist/accessible-autocomplete.min.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function Autocomplete () { }

  Autocomplete.prototype.start = function ($module) {
    this.$module = $module[0]
    var type = this.$module.dataset.autocompleteType

    if (type === 'with-hint-on-options') {
      this.initAutoCompleteWithHintOnOptions()
    } else if (type === 'without-narrowing-results') {
      this.initAutoCompleteWithoutNarrowingResults()
    } else {
      this.initAutoComplete()
    }
  }

  Autocomplete.prototype.initAutoComplete = function () {
    var $select = this.$module.querySelector('select')

    if (!$select) {
      return
    }

    // disabled eslint because we can not control the name of the constructor (expected to be EnhanceSelectElement)
    new window.accessibleAutocomplete.enhanceSelectElement({ // eslint-disable-line no-new, new-cap
      selectElement: $select,
      minLength: 3,
      showNoOptionsFound: true
    })
  }

  Autocomplete.prototype.initAutoCompleteWithHintOnOptions = function () {
    // Read options and associated data attributes and feed that as results for inputValueTemplate
    var $select = this.$module.querySelector('select')

    if (!$select) {
      return
    }

    var $options = $select.querySelectorAll('option')

    new window.accessibleAutocomplete({ // eslint-disable-line no-new, new-cap
      element: this.$module,
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

  Autocomplete.prototype.initAutoCompleteWithoutNarrowingResults = function () {
    // Read options and associated data attributes and feed that as results for inputValueTemplate
    var $select = this.$module.querySelector('select')

    if (!$select) {
      return
    }

    var $options = $select.querySelectorAll('option')
    var $selectedOption = $select.querySelector('option[selected]')
    if (!$selectedOption) {
      $selectedOption = $options[0]
    }
    var defaultValue = $selectedOption.textContent

    new window.accessibleAutocomplete({ // eslint-disable-line no-new, new-cap
      id: $select.id,
      name: $select.name,
      element: this.$module,
      showAllValues: true,
      defaultValue: defaultValue,
      autoselect: false,
      dropdownArrow: function (config) {
        return '<svg class="' + config.className + '" style="top: 8px;" viewBox="0 0 512 512" ><path d="M256,298.3L256,298.3L256,298.3l174.2-167.2c4.3-4.2,11.4-4.1,15.8,0.2l30.6,29.9c4.4,4.3,4.5,11.3,0.2,15.5L264.1,380.9  c-2.2,2.2-5.2,3.2-8.1,3c-3,0.1-5.9-0.9-8.1-3L35.2,176.7c-4.3-4.2-4.2-11.2,0.2-15.5L66,131.3c4.4-4.3,11.5-4.4,15.8-0.2L256,298.3  z"/></svg>'
      },
      source: function (query, syncResults) {
        var results = []
        $options.forEach(function ($el) {
          results.push($el.textContent)
        })
        syncResults(results)
      },
      onConfirm: function (result) {
        var value = result && result.value
        var options = [].filter.call($options, function (option) {
          return option.value === value
        })

        if (options.length) {
          options[0].selected = true
        }
      }
    })

    $select.parentNode.removeChild($select)
  }

  Modules.Autocomplete = Autocomplete
})(window.GOVUK.Modules)
