var GtmCopyPasteListener = {}

GtmCopyPasteListener.handleCopyPaste = function (prefix) {
  return function (event) {
    var element = event.target

    if (!element || !element.dataset) {
      return
    }

    var suffix = element.dataset.gtmSuffix
    var tracked = element.dataset.gtmCopyPasteTracking

    if (!suffix || !tracked) {
      return
    }

    window.dataLayer.push({
      event: prefix,
      dataGtm: prefix.toLowerCase() + '-' + suffix
    })
  }
}

window.addEventListener('copy', GtmCopyPasteListener.handleCopyPaste('Copy'))
window.addEventListener('paste', GtmCopyPasteListener.handleCopyPaste('Paste'))
