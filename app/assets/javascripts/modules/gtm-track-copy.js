function GTMCopyListener ($module, dataLayer) {
  this.$module = $module
  this.dataLayer = dataLayer || window.dataLayer
}

GTMCopyListener.prototype.handleCopyEvent = function (component) {
  this.dataLayer.push({
    'event': 'text-copied',
    'component': component
  })
}

GTMCopyListener.prototype.handlePasteEvent = function (component) {
  this.dataLayer.push({
    'event': 'text-pasted',
    'component': component
  })
}

GTMCopyListener.prototype.init = function () {
  var $module = this.$module
  var moduleName = this.$module.dataset.module
  $module.addEventListener('copy', function (e) {
    this.handleCopyEvent(moduleName)
  }.bind(this), false)

  $module.addEventListener('paste', function (e) {
    this.handlePasteEvent(moduleName)
  }.bind(this), false)
}

var $trackedComponents = document.querySelectorAll('[data-module="markdown-editor"], [data-module="copy-to-clipboard"]')
$trackedComponents.forEach(function ($component) {
  new GTMCopyListener($component).init()
})
