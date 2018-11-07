//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/all_components

//= require vendor/@webcomponents/custom-elements/custom-elements.js
//= require vendor/abortcontroller-polyfill/abortcontroller-polyfill.js
//= require vendor/nodelist-foreach-polyfill/index.js

//= require components/autocomplete.js
//= require components/error-alert.js
//= require components/image-cropper.js
//= require components/markdown-editor.js
//= require components/url-preview.js
//= require vendor/@alphagov/miller-columns-element/dist/index.umd.js

/**
 * contextual guidance need to be initialised after the rest of the components
 * as it may need to be applied to a JavaScript enchanced element (i.e. autocomplete)
 **/
//= require components/contextual-guidance.js

/* global Raven */
var $sentryDsn = document.querySelector('meta[name=sentry-dsn]')
var $sentryCurrentEnv = document.querySelector('meta[name=sentry-current-env]')

if ($sentryDsn && $sentryCurrentEnv) {
  Raven.config($sentryDsn.getAttribute('content'), {
    environment: $sentryCurrentEnv.getAttribute('content')
  }).install()
}
