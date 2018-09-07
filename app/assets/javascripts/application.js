//= require vendor/jquery-1.12.4
//= require govuk/modules
//= require vendor/nodelist-foreach-polyfill/index.js
//= require documents/edit
//= require components/markdown-editor.js
//= require components/error-alert.js
//= require components/autocomplete.js

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
