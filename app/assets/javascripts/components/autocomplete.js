//= require vendor/accessible-autocomplete/dist/accessible-autocomplete.min.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function Autocomplete () { }

  Autocomplete.prototype.start = function ($module) {
    this.$module = $module[0]
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

  Modules.Autocomplete = Autocomplete
})(window.GOVUK.Modules)
