//= require sortablejs/Sortable.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function ReorderableList () { }

  ReorderableList.prototype.start = function ($module) {
    this.$module = $module[0]

    this.sortable = window.Sortable.create(this.$module, { // eslint-disable-line new-cap
      chosenClass: 'app-c-reorderable-list__item--chosen',
      dragClass: 'app-c-reorderable-list__item--drag'
    })

    if (typeof window.matchMedia === 'function') {
      this.setupResponsiveChecks()
    } else {
      this.sortable.option('disabled', true)
    }
  }

  ReorderableList.prototype.setupResponsiveChecks = function () {
    var tabletBreakpoint = '40.0625em' // ~640px
    this.mediaQueryList = window.matchMedia('(min-width: ' + tabletBreakpoint + ')')
    this.mediaQueryList.addListener(this.checkMode.bind(this))
    this.checkMode()
  }

  ReorderableList.prototype.checkMode = function () {
    this.sortable.option('disabled', !this.mediaQueryList.matches)
  }

  Modules.ReorderableList = ReorderableList
})(window.GOVUK.Modules)
