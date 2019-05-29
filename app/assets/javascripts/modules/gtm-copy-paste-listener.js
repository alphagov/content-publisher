var GtmCopyPasteListener = {}

GtmCopyPasteListener.handleCopy = function (event) {
  var element = event.target

  if (!element.hasAttribute('data-gtm-copy-paste-tracking')) {
    return
  }

  window.dataLayer.push({
    'event': 'text-copied'
  })
}

GtmCopyPasteListener.handlePaste = function (event) {
  var element = event.target

  if (!element.hasAttribute('data-gtm-copy-paste-tracking')) {
    return
  }

  window.dataLayer.push({
    'event': 'text-pasted'
  })
}

window.addEventListener('copy', GtmCopyPasteListener.handleCopy)
window.addEventListener('paste', GtmCopyPasteListener.handlePaste)
