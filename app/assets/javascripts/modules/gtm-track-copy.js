function GTMCopyListener ($module, dataLayer) {
  this.$module = $module
  this.dataLayer = dataLayer || window.dataLayer
}

GTMCopyListener.prototype.handleCopyEvent = function (value) {
  this.dataLayer.push({
    'event': 'text-copied',
    'element': value
  })
}

GTMCopyListener.prototype.handlePasteEvent = function (value) {
  this.dataLayer.push({
    'event': 'text-pasted',
    'element': value
  })
}

GTMCopyListener.prototype.init = function () {
  var $module = this.$module
  var datasetValue = this.$module.dataset.gtmCopyPasteTracking
  $module.addEventListener('copy', function (e) {
    this.handleCopyEvent(datasetValue)
  }.bind(this), false)

  $module.addEventListener('paste', function (e) {
    this.handlePasteEvent(datasetValue)
  }.bind(this), false)
}

var $trackedComponents = document.querySelectorAll('[data-gtm-copy-paste-tracking]')
$trackedComponents.forEach(function ($component) {
  new GTMCopyListener($component).init()
})
