'use strict'

/* global restrict */

restrict('edit-document-form', function (editDocumentForm) {
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

  documentTitle.onblur = function () {
    var path = editDocumentForm.getAttribute('data-generate-path-path')
    var url = new URL(document.location.origin + path)

    if (!documentTitle.value) {
      showNoTitleMessage()
      return
    } else {
      url.searchParams.append('title', documentTitle.value)
    }

    window.fetch(url, {
      credentials: 'include'
    }).then(function (response) {
      if (!response.ok) {
        throw Error('Unable to generate response.')
      }
      response.json().then(function (result) {
        showPathPreview(result['base_path'])
      })
    }).catch(showErrorMessage)
  }

  documentTitle.onblur()
})
