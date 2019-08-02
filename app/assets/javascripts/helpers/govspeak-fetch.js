window.GovspeakFetch = { }

window.GovspeakFetch.getBody = function (text) {
  var path = document.location.pathname
  var segments = path.split('/')
  var documentSegment = segments[1]
  var editionSegment = segments[2]
  path = [documentSegment, editionSegment, 'govspeak-preview'].join('/')

  var url = new URL(document.location.origin + '/' + path)

  var formData = new window.FormData()
  formData.append('govspeak', text)

  var controller = new window.AbortController()
  var options = { credentials: 'include', signal: controller.signal, method: 'POST', body: formData }
  setTimeout(function () { controller.abort() }, 15000)

  return window.fetch(url, options).then(function (response) { return response.text() })
}
