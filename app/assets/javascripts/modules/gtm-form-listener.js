function GTMFormListener ($form, dataLayer) {
  this.$form = $form
  this.dataLayer = dataLayer || window.dataLayer
}

GTMFormListener.prototype.handleSubmit = function (event) {
  var eventName = this.$form.dataset.gtm
  var message

  var inputElements = this.$form.querySelectorAll('input:checked')
  inputElements.forEach(function (element) {
    if (element.value.length > 0) {
      message = {}
      message[eventName] = {}
      message[eventName][element.name] = element.value
      this.dataLayer.push(message)
    }
  }, this)
}

GTMFormListener.prototype.init = function () {
  if (!this.$form) {
    return
  }

  this.$form.addEventListener('submit', function (e) {
    this.handleSubmit(e)
  }.bind(this), false)
}

GTMFormListener.init = function (dataLayer) {
  document.querySelectorAll('form[data-gtm]').forEach(function (element) {
    new GTMFormListener(element, dataLayer).init()
  })
}

GTMFormListener.init()
