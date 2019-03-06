var GtmCopyPasteListener = {}

GtmCopyPasteListener.handleCopy = function (event) {
  var element = event.target

  if (!element.hasAttribute('data-gtm-copy-paste-tracking')) {
    return
  }

  window.dataLayer.push({
    'event': 'text-copied',
    'element': element.dataset.gtmCopyPasteTracking
  })
}

GtmCopyPasteListener.handlePaste = function (event) {
  var element = event.target

  if (!element.hasAttribute('data-gtm-copy-paste-tracking')) {
    return
  }

  window.dataLayer.push({
    'event': 'text-pasted',
    'element': element.dataset.gtmCopyPasteTracking
  })
}

window.addEventListener('copy', GtmCopyPasteListener.handleCopy)
window.addEventListener('paste', GtmCopyPasteListener.handlePaste)
