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

    if (!this.hasDetailsSupport()) {
      this.closeToolbarDropdown()
      this.$title.addEventListener('click', ToolbarDropdown.prototype.handleTitleClick.bind(this), true)
    }

    $buttons.forEach(function ($button) {
      $button.addEventListener('click', ToolbarDropdown.prototype.handleListItemClick.bind(this), true)
    }, this)

    $links.forEach(function ($link) {
      $link.addEventListener('click', ToolbarDropdown.prototype.handleListItemClick.bind(this), true)
    }, this)
  }

  ToolbarDropdown.prototype.handleBlur = function (event) {
    var target = event.relatedTarget || // Chrome
                 event.explicitOriginalTarget || // Firefox
                 event.target || // Safari
                 document.activeElement // IE
    if (!this.$module.contains(target)) {
      this.closeToolbarDropdown()
    }
  }

  ToolbarDropdown.prototype.handleTitleClick = function (event) {
    this.toggleDropdownContainer()
  }

  ToolbarDropdown.prototype.handleListItemClick = function (event) {
    this.closeToolbarDropdown()
  }

  ToolbarDropdown.prototype.closeToolbarDropdown = function (event) {
    this.$module.removeAttribute('open')
  }

  ToolbarDropdown.prototype.toggleDropdownContainer = function (event) {
    if (!this.$module.hasAttribute('open')) {
      this.$module.setAttribute('open', 'open')
    } else {
      this.$module.removeAttribute('open')
    }
  }

  ToolbarDropdown.prototype.hasDetailsSupport = function () {
    // calling `createElement('DETAILS')` in a browser with support for the <details> element it returns
    // an HTMLDetailsElement object which has an `open` attribute inhertited from the prototype, otherwise it returns
    // an HTMLUnknownElementPrototype object which does not have the `open` attribute
    var el = document.createElement('DETAILS')
    if ('open' in el) return true
  }

  Modules.ToolbarDropdown = ToolbarDropdown
})(window.GOVUK.Modules)
