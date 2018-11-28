function ContextualGuidance ($module) {
  if (!$module) $module = document
  this.$module = $module
  this.$fields = $module.querySelectorAll('[data-contextual-guidance]')
}

ContextualGuidance.prototype.handleFocus = function (event) {
  // Get the target element
  var target = event.target
  var guidanceId = ContextualGuidance.prototype.getGuidanceId(target)

  // If we have guidance for the field
  if (guidanceId) {
    var guidance = document.querySelector('#' + guidanceId)
    ContextualGuidance.prototype.hideAllGuidance()
    ContextualGuidance.prototype.showGuidance(guidance)
  }
}

ContextualGuidance.prototype.showGuidance = function (element) {
  if (element) {
    element.style.display = 'block'
  }
}

ContextualGuidance.prototype.hideAllGuidance = function () {
  var $guidances = document.querySelectorAll('.app-c-contextual-guidance-wrapper')
  $guidances.forEach(function ($guidance) {
    $guidance.style.display = 'none'
  })
}

ContextualGuidance.prototype.getGuidanceId = function (element) {
  var guidanceId = element.getAttribute('data-contextual-guidance')
  return guidanceId
}

ContextualGuidance.prototype.init = function () {
  var $fields = this.$fields

  /**
  * Loop over all items with [data-contextual-guidance]
  * Check if they have a matching contextual guidance
  * If they do, add event listener on focus
  **/
  $fields.forEach(function ($field) {
    var guidanceId = ContextualGuidance.prototype.getGuidanceId($field)
    if (!guidanceId) {
      return
    }
    $field.addEventListener('focus', ContextualGuidance.prototype.handleFocus)
  })
}

// Initialise guidance at document level
var guidance = new ContextualGuidance()
guidance.init(document)
