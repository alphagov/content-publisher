export default function restrict (module, callback) {
  var query = '[data-module="' + module + '"]'
  var elements = document.querySelectorAll(query)
  elements.forEach(callback)
}
