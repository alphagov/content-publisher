var GtmReorderListener = {}

GtmReorderListener.handleReorder = function (eventName, dataGtm) {
  return function (event) {
    window.dataLayer.push({
      event: eventName,
      dataGtm: dataGtm
    })
  }
}

window.addEventListener('reorder-move-up', GtmReorderListener.handleReorder('Click', 'reorder-move-up'))
window.addEventListener('reorder-move-down', GtmReorderListener.handleReorder('Click', 'reorder-move-down'))
window.addEventListener('reorder-drag', GtmReorderListener.handleReorder('Drag', 'reorder-drag'))
