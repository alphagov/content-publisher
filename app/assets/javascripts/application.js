'use strict'

document.onreadystatechange = function () {
  var csrfElement = document.querySelector('meta[name="csrf-token"]')
  var csrf = csrfElement ? csrfElement.content : ""
  if (document.readyState === 'interactive') {
    var basePath = document.getElementById('base-path-id')
    var documentTitle = document.getElementById('document-title-id')
    if (basePath==null || documentTitle==null) {return;}
    var pathArray = document.location.pathname.split('/')
    var documentId = pathArray[2]
    var url = new URL(document.location.origin + '/documents/' + documentId + '/generate-path')
    documentTitle.onblur = function () {
      if (!documentTitle.value) {
        basePath.innerHTML = "You haven’t entered a title yet."
        return
      }
      url.searchParams.append('title', documentTitle.value)
      window.fetch(url, {
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-CSRF-Token': csrf
        },
      }).then(function(response) {
        response.json().then(function (result) {
          if (result.available) {
            basePath.innerHTML = 'www.gov.uk' + result['base_path']
          } else {
            basePath.innerHTML = 'Path is taken, please edit the title.'
          }
        })
      })
    }
  }
}
