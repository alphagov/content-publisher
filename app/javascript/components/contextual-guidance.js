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
    element.classList.remove('govuk-visually-hidden')
  }
}

ContextualGuidance.prototype.hideAllGuidance = function () {
  var $guidances = document.querySelectorAll('.app-c-contextual-guidance-wrapper')
  $guidances.forEach(function ($guidance) {
    $guidance.classList.add('govuk-visually-hidden')
  })
}

ContextualGuidance.prototype.getGuidanceId = function (element) {
  var guidanceId = element.getAttribute('data-contextual-guidance')
  return guidanceId
}

ContextualGuidance.prototype.init = function () {
  var $fields = this.$fields

  this.hideAllGuidance()

  /**
  * Loop over all items with [data-contextual-guidance]
  * Check if they have a matching contextual guidance
  * If they do, add event listener on focus
  **/
  $fields.forEach(function ($field) {
    var guidanceId = ContextualGuidance.prototype.getGuidanceId($field)

    if (!guidanceId || !document.querySelector('#' + guidanceId)) {
      return
    }
    $field.addEventListener('focus', ContextualGuidance.prototype.handleFocus)
  })
}

export default ContextualGuidance
