window.ModalFetch = { }

window.ModalFetch.getLink = function (item) {
  var controller = new window.AbortController()
  var headers = { 'Content-Publisher-Rendering-Context': 'modal' }
  var options = { credentials: 'include', signal: controller.signal, headers: headers }
  setTimeout(function () { controller.abort() }, 5000)

  return window.fetch(item.href, options)
    .then(function (response) {
      if (!response.ok) {
        window.ModalFetch.debug(response)
        return window.Promise.reject('Unable to fetch modal content')
      }

      return response.text()
        .then(function (text) {
          return { body: text }
        })
    })
}

window.ModalFetch.postForm = function (form) {
  var controller = new window.AbortController()
  setTimeout(function () { controller.abort() }, 10000)

  var options = {
    credentials: 'include',
    signal: controller.signal,
    headers: { 'Content-Publisher-Rendering-Context': 'modal' },
    redirect: 'follow',
    method: 'POST',
    body: (new window.FormData(form))
  }

  return window.fetch(form.action, options)
    .then(function (response) {
      if (!response.ok && response.status !== 422) {
        window.ModalFetch.debug(response)
        return window.Promise.reject('Unable to fetch modal content')
      }

      return response.text()
        .then(function (text) {
          return { body: text, unprocessableEntity: response.status === 422 }
        })
    })
}

window.ModalFetch.debug = function (response) {
  var envMeta = document.querySelector('meta[name="app-environment"]')

  if (envMeta.content !== 'production') {
    return
  }

  response.text().then(console.debug)
}
