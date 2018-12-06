function WarnBeforeUnload ($module, $scope) {
  if (!$module) $module = window
  if (!$scope) $scope = document
  this.$module = $module
  this.$forms = $scope.querySelectorAll('[data-warn-before-unload=true]')
}

WarnBeforeUnload.prototype.init = function () {
  var _this = this
  if (!this.$forms) return

  this.$forms.forEach(function ($form) {
    $form.addEventListener('change', function () {
      _this.$module.addEventListener('beforeunload', _this.handleBeforeUnload)
    })
    $form.addEventListener('submit', function () {
      _this.$module.removeEventListener('beforeunload', _this.handleBeforeUnload)
    })
  })
}

WarnBeforeUnload.prototype.handleBeforeUnload = function (e) {
  e.preventDefault()
  e.returnValue = true
}

// Initialise WarnBeforeUnload at window level
var _warnBeforeUnload = new WarnBeforeUnload(window, document)
_warnBeforeUnload.init()
