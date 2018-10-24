function ErrorAlert ($module) {
  this.$module = $module
}

ErrorAlert.prototype.init = function () {
  var $module = this.$module
  if (!$module) {
    return
  }
  window.addEventListener('load', this.focus)
}

ErrorAlert.prototype.focus = function () {
  var $module = this.$module
  $module.focus()
}

var $errorAlert = document.querySelector('[data-module="error-alert"]')
if ($errorAlert) {
  new ErrorAlert($errorAlert).init()
}
