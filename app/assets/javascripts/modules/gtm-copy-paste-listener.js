var GtmCopyPasteListener = {}

GtmCopyPasteListener.handleCopyPaste = function (eventName) {
  return function (event) {
    var element = event.target

    if (!element) {
      return
    }

    var dataGtm = element.dataset.gtm
    var tracked = element.dataset.gtmCopyPasteTracking

    if (!dataGtm || !tracked) {
      return
    }

    window.dataLayer.push({
      event: eventName,
      dataGtm: dataGtm
    })
  }
}

window.addEventListener('copy', GtmCopyPasteListener.handleCopyPaste('Copy'))
window.addEventListener('paste', GtmCopyPasteListener.handleCopyPaste('Paste'))
