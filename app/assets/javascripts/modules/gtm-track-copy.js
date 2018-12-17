function GTMCopyListener () { }

GTMCopyListener.prototype.handleCopyEvent = function () {
  window.dataLayer.push({
    'event': 'text-copied'
  })
}

GTMCopyListener.prototype.handlePasteEvent = function () {
  window.dataLayer.push({
    'event': 'text-pasted'
  })
}

GTMCopyListener.prototype.init = function () {
  document.addEventListener('copy', function (e) {
    this.handleCopyEvent(e)
  }.bind(this), false)

  document.addEventListener('paste', function (e) {
    this.handlePasteEvent(e)
  }.bind(this), false)
}

new GTMCopyListener().init()
