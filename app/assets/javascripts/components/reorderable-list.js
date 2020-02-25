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
  }

  Modules.ReorderableList = ReorderableList
})(window.GOVUK.Modules)
