//= require vendor/jquery-1.12.4
//= require govuk/modules
//= require vendor/nodelist-foreach-polyfill/index.js
//= require documents/edit
//= require components/markdown-editor.js
//= require components/contextual-guidance.js
//= require components/error-alert.js

/* global Raven */

var $sentryDsn = document.querySelector('meta[name=sentry-dsn]')
var $sentryCurrentEnv = document.querySelector('meta[name=sentry-current-env]')

if ($sentryDsn && $sentryCurrentEnv) {
  Raven.config($sentryDsn.getAttribute('content'), {
    environment: $sentryCurrentEnv.getAttribute('content')
  }).install()
}
