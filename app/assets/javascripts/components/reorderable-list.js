//= require sortablejs/Sortable.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function ReorderableList () { }

  ReorderableList.prototype.start = function ($module) {
    this.$module = $module[0]
    this.$upButtons = this.$module.querySelectorAll('.js-reorderable-list-up')
    this.$downButtons = this.$module.querySelectorAll('.js-reorderable-list-down')

    this.sortable = window.Sortable.create(this.$module, { // eslint-disable-line new-cap
      chosenClass: 'app-c-reorderable-list__item--chosen',
      dragClass: 'app-c-reorderable-list__item--drag'
    })

    if (typeof window.matchMedia === 'function') {
      this.setupResponsiveChecks()
    } else {
      this.sortable.option('disabled', true)
    }

    var boundOnClickUpButton = this.onClickUpButton.bind(this)
    this.$upButtons.forEach(function (button) {
      button.addEventListener('click', boundOnClickUpButton)
    })

    var boundOnClickDownButton = this.onClickDownButton.bind(this)
    this.$downButtons.forEach(function (button) {
      button.addEventListener('click', boundOnClickDownButton)
    })
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

  ReorderableList.prototype.onClickUpButton = function (e) {
    var item = e.target.closest('.app-c-reorderable-list__item')
    var previousItem = item.previousElementSibling
    if (item && previousItem) {
      item.parentNode.insertBefore(item, previousItem)
    }
    // if triggered by keyboard preserve focus on button
    if (e.detail === 0) {
      if (item !== item.parentNode.firstElementChild) {
        e.target.focus()
      } else {
        e.target.nextElementSibling.focus()
      }
    }
  }

  ReorderableList.prototype.onClickDownButton = function (e) {
    var item = e.target.closest('.app-c-reorderable-list__item')
    var nextItem = item.nextElementSibling
    if (item && nextItem) {
      item.parentNode.insertBefore(item, nextItem.nextElementSibling)
    }
    // if triggered by keyboard preserve focus on button
    if (e.detail === 0) {
      if (item !== item.parentNode.lastElementChild) {
        e.target.focus()
      } else {
        e.target.previousElementSibling.focus()
      }
    }
  }

  Modules.ReorderableList = ReorderableList
})(window.GOVUK.Modules)
