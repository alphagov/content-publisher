'use strict';

document.onreadystatechange = function () {
  var csrf = document.querySelector('meta[name="csrf-token"]').content;
  if (document.readyState === "interactive") {
    var document_title = document.getElementById("document-title-id");
    var pathArray = document.location.pathname.split('/');
    var documentId = pathArray[2];
    var url = '/documents/' + documentId + '/generate-path';
    document_title.onblur = function () {
      fetch(url, {
        method: "POST",
        credentials: "include",
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "X-CSRF-Token": csrf,
        },
        body: JSON.stringify({ title: document_title.value })
      }).then(response => response.json().then(function(result) {
        var base_path = document.getElementById("base-path-id");
        if (result.reserved) {
          base_path.innerHTML = "www.gov.uk" + result.base_path;
        } else {
          base_path.innerHTML = "Path is taken, please edit the title.";
        }
      }));
    };
  }
};
