function ErrorAlert ($module) {
  this.$module = $module
}

ErrorAlert.prototype.init = function () {
  var $module = this.$module
  if (!$module) {
    return
  }
  window.addEventListener('load', function () {
    $module.focus()
  })
}

export default ErrorAlert
