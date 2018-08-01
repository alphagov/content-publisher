'use strict';

document.onreadystatechange = function () {
  var csrf = document.querySelector('meta[name="csrf-token"]').content
  if (document.readyState === "interactive") {
    var document_title = document.getElementById("document-title-id");
    document_title.onblur = function () {
      fetch('/documents/generate-path', {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "X-CSRF-Token": csrf,
        },
        body: JSON.stringify({ title: document_title.value })
      }).then(function (response) {
        var res = response.json()
        if (res.reserved) {
          var base_path = document.getElementById("base-path-id");
          base_path.value = res.base_path;
        }
      });
    };
  }
}
