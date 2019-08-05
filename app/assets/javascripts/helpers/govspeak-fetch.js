window.GovspeakFetch = { }

window.GovspeakFetch.getBody = function (text) {
  var documentId = document.location.pathname.match('/documents/([^/]*)/')[1]

  if (!documentId) {
    console.error('Could not find document ID in pathname')
    return
  }

  var path = '/documents/' + documentId + '/govspeak-preview'

  var url = new URL(document.location.origin + path)

  var formData = new window.FormData()
  formData.append('govspeak', text)

  var controller = new window.AbortController()
  var options = { credentials: 'include', signal: controller.signal, method: 'POST', body: formData }
  setTimeout(function () { controller.abort() }, 15000)

  return window.fetch(url, options).then(function (response) { return response.text() })
}
