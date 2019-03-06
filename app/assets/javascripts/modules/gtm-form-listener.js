var GtmFormListener = {}

GtmFormListener.handleSubmit = function (event) {
  var form = event.target

  if (!form.hasAttribute('data-gtm')) {
    return
  }

  var eventName = form.dataset.gtm
  var inputElements = form.querySelectorAll('input:checked')
  var message

  inputElements.forEach(function (element) {
    if (element.value.length > 0) {
      message = {}
      message[eventName] = {}
      message[eventName][element.name] = element.value
      window.dataLayer.push(message)
    }
  }, this)
}

window.addEventListener('submit', GtmFormListener.handleSubmit)
