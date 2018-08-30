export default function (editDocumentForm) {
  var urlPreview = document.getElementById('url-preview-id')
  var basePath = document.getElementById('base-path-id')
  var documentTitle = document.getElementById('document-title-id')
  var noTitle = document.getElementById('no-title-id')
  var errorGeneratingPath = document.getElementById('error-generating-path-id')
  var path = editDocumentForm.getAttribute('data-generate-path-path')

  var showErrorMessage = function () {
    urlPreview.setAttribute('class', 'app-hidden')
    noTitle.setAttribute('class', 'app-hidden')
    errorGeneratingPath.removeAttribute('class')
  }

  var showNoTitleMessage = function () {
    noTitle.removeAttribute('class')
    urlPreview.setAttribute('class', 'app-hidden')
    errorGeneratingPath.setAttribute('class', 'app-hidden')
  }

  var showPathPreview = function (path) {
    noTitle.setAttribute('class', 'app-hidden')
    errorGeneratingPath.setAttribute('class', 'app-hidden')
    urlPreview.removeAttribute('class')
    basePath.innerHTML = path
  }

  var fetchPathPreview = function () {
    var url = new URL(document.location.origin + path)
    url.searchParams.append('title', documentTitle.value)

    var controller = new AbortController()
    var options = { credentials: 'include', signal: controller.signal }
    setTimeout(() => controller.abort(), 5000)

    return window.fetch(url, options)
      .then(function (response) {
        if (!response.ok) {
          throw Error('Unable to generate response.')
        }

        return response.text()
      })
  }

  documentTitle.onblur = function () {
    if (!documentTitle.value) {
      showNoTitleMessage()
      return
    }

    fetchPathPreview()
      .then(showPathPreview)
      .catch(showErrorMessage)
  }

  documentTitle.onblur()
}
