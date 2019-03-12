var GtmSelectedTopicsListener = {}

GtmSelectedTopicsListener.handleSubmit = function (event) {
  var form = event.target

  if (!form.hasAttribute('data-gtm-selected-topics')) {
    return
  }

  var selectedMillerColumns = form.querySelector('miller-columns-selected')

  if (!selectedMillerColumns || !selectedMillerColumns.selectedTopicNames) {
    return
  }

  selectedMillerColumns.selectedTopicNames().forEach(function (item) {
    window.dataLayer.push({
      event: 'topic-selection',
      value: item.join(' > ')
    })
  })
}

window.addEventListener('submit', GtmSelectedTopicsListener.handleSubmit)
