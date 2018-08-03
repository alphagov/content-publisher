'use strict'

document.onreadystatechange = function () {
  if (document.readyState === 'interactive') {
    var editDocumentForm = document.querySelector('.edit_document')
    if (editDocumentForm == null) { return } // only run on edit document page
    var urlPreview = document.getElementById('url-preview-id')
    var basePath = document.getElementById('base-path-id')
    var documentTitle = document.getElementById('document-title-id')
    var noTitle = document.getElementById('no-title-id')
    var errorGeneratingPath = document.getElementById('error-generating-path-id')
    var showErrorMessage = function () {
      urlPreview.setAttribute('class', 'app-hidden')
      noTitle.setAttribute('class', 'app-hidden')
      errorGeneratingPath.removeAttribute('class')
    }
    documentTitle.onblur = function () {
      var url = new URL(document.location.origin + editDocumentForm.getAttribute('data-generate-path-path'))
      if (!documentTitle.value) {
        noTitle.removeAttribute('class')
        urlPreview.setAttribute('class', 'app-hidden')
        errorGeneratingPath.setAttribute('class', 'app-hidden')
        return
      }
      url.searchParams.append('title', documentTitle.value)
      window.fetch(url, {
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json; charset=utf-8'
        }
      }).then(function (response) {
        if (!response.ok) {
          throw Error('Unable to generate response.')
        }
        response.json().then(function (result) {
          if (result.available) {
            noTitle.setAttribute('class', 'app-hidden')
            errorGeneratingPath.setAttribute('class', 'app-hidden')
            urlPreview.removeAttribute('class')
            basePath.innerHTML = result['base_path']
          } else {
            showErrorMessage()
          }
        })
      }).catch(showErrorMessage)
    }
    documentTitle.onblur()
  }
}
