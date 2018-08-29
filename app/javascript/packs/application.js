// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'nodelist-foreach-polyfill'
import restrict from '../restrict'
import editDocumentForm from '../documents/edit'
import MarkdownEditor from '../components/markdown-editor'
import ContextualGuidance from '../components/contextual-guidance'
import ErrorAlert from '../components/error-alert'
import Raven from 'raven-js'

var $sentryDsn = document.querySelector('meta[name=sentry-dsn]')
var $sentryCurrentEnv = document.querySelector('meta[name=sentry-current-env]')

if ($sentryDsn && $sentryCurrentEnv) {
  // set as global variable for console usage
  window.Raven = Raven.config($sentryDsn.getAttribute('content'), {
    environment: $sentryCurrentEnv.getAttribute('content')
  }).install()
}

restrict('edit-document-form', editDocumentForm)
restrict('markdown-editor', ($el) => new MarkdownEditor($el).init())
restrict('error-alert', ($el) => new ErrorAlert($el).init())

// Initialise guidance at document level
var guidance = new ContextualGuidance()
guidance.init(document)
