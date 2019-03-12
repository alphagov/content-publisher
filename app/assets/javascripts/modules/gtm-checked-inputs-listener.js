var GtmCheckedInputsListener = {}

GtmCheckedInputsListener.handleSubmit = function (event) {
  var form = event.target

  if (!form.hasAttribute('data-gtm-checked-inputs')) {
    return
  }

  var eventName = form.dataset.gtmCheckedInputs
  var inputElements = form.querySelectorAll('input:checked')

  inputElements.forEach(function (element) {
    if (element.value.length > 0) {
      window.dataLayer.push({
        event: 'checked-inputs.' + eventName,
        value: element.name + ': ' + element.value
      })
    }
  })
}

window.addEventListener('submit', GtmCheckedInputsListener.handleSubmit)
