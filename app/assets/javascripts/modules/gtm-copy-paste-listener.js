function GtmCopyPasteListener () { }

GtmCopyPasteListener.prototype.handleCopy = function (event) {
  var element = event.target

  if (!element.hasAttribute('data-gtm-copy-paste-tracking')) {
    return
  }

  window.dataLayer.push({
    'event': 'text-copied',
    'element': element.dataset.gtmCopyPasteTracking
  })
}

GtmCopyPasteListener.prototype.handlePaste = function (event) {
  var element = event.target

  if (!element.hasAttribute('data-gtm-copy-paste-tracking')) {
    return
  }

  window.dataLayer.push({
    'event': 'text-pasted',
    'element': element.dataset.gtmCopyPasteTracking
  })
}

GtmCopyPasteListener.prototype.init = function () {
  window.addEventListener('copy', this.handleCopy.bind(this))
  window.addEventListener('paste', this.handlePaste.bind(this))
}

new GtmCopyPasteListener().init()
