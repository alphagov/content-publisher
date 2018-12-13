function GTMCopyListener () { }

GTMCopyListener.prototype.getSelectionText = function () {
  var text = ''
  if (window.getSelection) {
    text = window.getSelection().toString()
  } else if (document.selection && document.selection.type !== 'Control') {
    text = document.selection.createRange().text
  }
  return text
}

GTMCopyListener.prototype.handleCopyEvent = function () {
  window.dataLayer.push({
    'event': 'text-copied',
    'copiedText': this.getSelectionText(),
    'textLength': this.getSelectionText().length
  })
}

GTMCopyListener.prototype.handlePasteEvent = function () {
  window.dataLayer.push({
    'event': 'text-pasted',
    'copiedText': 'N/A'
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
