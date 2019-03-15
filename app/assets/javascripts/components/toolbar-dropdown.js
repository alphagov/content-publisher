window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function ToolbarDropdown () { }

  ToolbarDropdown.prototype.start = function ($module) {
    this.$module = $module[0]
    this.$title = this.$module.querySelector('.app-c-toolbar-dropdown__title')
    this.$container = this.$module.querySelector('.app-c-toolbar-dropdown__container')
    this.$module.addEventListener('blur', ToolbarDropdown.prototype.handleBlur.bind(this), true)

    var $buttons = this.$module.querySelectorAll('.app-c-toolbar-dropdown__button')
    var $links = this.$module.querySelectorAll('.app-c-toolbar-dropdown__link')

    $buttons.forEach(function ($button) {
      $button.addEventListener('click', ToolbarDropdown.prototype.handleClick.bind(this), true)
    }, this)

    $links.forEach(function ($link) {
      $link.addEventListener('click', ToolbarDropdown.prototype.handleClick.bind(this), true)
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

  ToolbarDropdown.prototype.handleClick = function (event) {
    this.closeToolbarDropdown()
  }

  ToolbarDropdown.prototype.closeToolbarDropdown = function (event) {
    if (this.$module.hasAttribute('open')) {
      this.$title.click()
    }
  }

  Modules.ToolbarDropdown = ToolbarDropdown
})(window.GOVUK.Modules)
