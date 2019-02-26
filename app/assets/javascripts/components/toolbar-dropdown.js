window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function ToolbarDropdown () { }

  ToolbarDropdown.prototype.start = function ($module) {
    this.$module = $module[0]
    this.$title = this.$module.querySelector('.app-c-toolbar-dropdown__title')
    this.$container = this.$module.querySelector('.app-c-toolbar-dropdown__container')
    this.$buttons = this.$module.querySelectorAll('.app-c-toolbar-dropdown__button')

    this.$module.addEventListener('blur', ToolbarDropdown.prototype.handleBlur.bind(this), true)
    this.$buttons.forEach(function ($button) {
      $button.addEventListener('click', ToolbarDropdown.prototype.handleButtonClick.bind(this), true)
    }, this)
  }

  ToolbarDropdown.prototype.handleBlur = function (event) {
    var target = event.relatedTarget
    if (!target) {
      target = document.activeElement
    }

    if (!this.$module.contains(target)) {
      this.closeToolbarDropdown()
    }
  }

  ToolbarDropdown.prototype.handleButtonClick = function (event) {
    this.closeToolbarDropdown()
  }

  ToolbarDropdown.prototype.closeToolbarDropdown = function (event) {
    if (this.$module.hasAttribute('open')) {
      this.$title.click()
    }
  }

  Modules.ToolbarDropdown = ToolbarDropdown
})(window.GOVUK.Modules)
