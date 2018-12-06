function WarnBeforeUnload ($module) {
  this.$module = $module
}

WarnBeforeUnload.prototype.init = function () {
  this.$module.addEventListener('change', function () {
    window.addEventListener('beforeunload', WarnBeforeUnload.handleBeforeUnload)
  })

  this.$module.addEventListener('submit', function () {
    window.removeEventListener('beforeunload', WarnBeforeUnload.handleBeforeUnload)
  })
}

// This is a static method on WarnBeforeUnload so that the same function can be
// added as an event listener no matter which forms on the page use this
// if this was a prototype method we'd have potentially multiple listeners
// registered
WarnBeforeUnload.handleBeforeUnload = function (e) {
  e.preventDefault()
  var message = 'Your changes will not be saved'
  e.returnValue = message
  return message
}

document.querySelectorAll('[data-warn-before-unload=true]').forEach(function (form) {
  var module = new WarnBeforeUnload(form)
  module.init()
})
