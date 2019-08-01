window.FetchContent = { }

window.FetchContent.govspeak = function (text, path) {
  if (!path) {
    return window.Promise.reject('Govspeak path not set')
  }
  var url = new URL(document.location.origin + path)

  var formData = new window.FormData()
  formData.append('govspeak', text)

  var controller = new window.AbortController()
  var options = { credentials: 'include', signal: controller.signal, method: 'POST', body: formData }
  setTimeout(function () { controller.abort() }, 15000)

  return window.fetch(url, options).then(function (response) { return response.text() })
}
