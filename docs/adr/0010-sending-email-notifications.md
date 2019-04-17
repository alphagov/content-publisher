# 10. Sending email notifiations

[notify]: https://www.notifications.service.gov.uk/
[notify-features]: https://www.notifications.service.gov.uk/features
[notify-allowed-list]: https://docs.notifications.service.gov.uk/ruby.html#team-and-whitelist
[notify-gem]: https://docs.notifications.service.gov.uk/ruby.html#ruby-client-documentation
[notify-gem-send-email]: https://docs.notifications.service.gov.uk/ruby.html#send-an-email
[action-mailer]: https://guides.rubyonrails.org/action_mailer_basics.html
[action-mailer-interceptor]: https://guides.rubyonrails.org/action_mailer_basics.html#intercepting-emails
[active-job]: https://edgeguides.rubyonrails.org/active_job_basics.html
[active-job-retry]: https://edgeguides.rubyonrails.org/active_job_basics.html#retrying-or-discarding-failed-jobs
[active-job-sidekiq]: https://github.com/mperham/sidekiq/wiki/Active-Job
[active-job-sidekiq-retry]: https://github.com/mperham/sidekiq/wiki/Active-Job#customizing-error-handling
[active-job-improvements]: https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
[sidekiq]: https://github.com/mperham/sidekiq
[sidekiq-govuk]: https://github.com/alphagov/govuk_sidekiq
[sidekiq-grafana]: https://grafana.production.govuk.digital/dashboard/file/sidekiq.json?refresh=1m&orgId=1
[sidekiq-sentry]: https://docs.sentry.io/clients/ruby/#reporting-failures
[raven]: https://github.com/getsentry/raven-ruby
[raven-active-job]: https://github.com/getsentry/raven-ruby/blob/master/lib/raven/integrations/rails/active_job.rb
[consequences-sidekiq-worker]: https://github.com/alphagov/content-publisher/commit/88e27840f7a7f812d83c5878503cc6aece01127b
[consequences-sidekiq-abort]: https://github.com/alphagov/content-publisher/commit/ce13ccd34e967e091526adb20938b815faf5a912

Date: 2019-04-09

## Context

In order to send email notifications about user actions, such as publishing a document, we need to:

   - Work out who should receive the email
   - Generate the content for the email (subject and body)
   - Send the email to the recipient(s)

We don't anticipate sending email to be a critical step of any user action, but it is still a step that is prone to error and delay, due to interaction with external systems. We should ensure sending emails is robust against transient failure and that emails are only sent when we are confident they are accurate i.e. after DB updates and critical API calls.

We should have a means of sending notifications in non-production environments, which allows us to see what notifications would be sent in production, but prevents the emails from being sent to the intended recipient(s). It should also be possible to see the notifications we have sent in production in order to debug issues if users report they are not receiving notifications, or that the content of the notifications is incorrect.

## Decision

We will use [GOV.UK Notify][notify] in combination with [Action Mailer][action-mailer], [Active Job][active-job] and [Sidekiq][sidekiq].

### GOV.UK Notify

We will use [GOV.UK Notify][notify] to handle the low-level concerns of sending emails:

   - This avoids having to setup our own mechanism for sending email, including logic to handle low-level errors and retries, which are [handled by Notify by default][notify-features]
   - Notify provide a [Ruby gem][notify-gem] that makes it easy to integrate the service into our app, without specific knowledge of the underlying APIs
   - We can use the [Notify dashboard][notify-features] to see emails we have sent, logs for individual emails, as well as aggregate stats over all emails
   - Notify provides the facility to restrict the recipients of emails to a [specific list][notify-allowed-list], which we can use to restrict notifications outside of production

In order to integrate Notify with our app, we will setup 3 'GOV.UK Publishing' accounts as follows:

   - One account will be for production use by any GOV.UK publishing app
   - The other two accounts will be for testing notifications on integration and staging

We agreed to use the generic 'GOV.UK Publishing' name as part of a wider GOV.UK strategy to have a single Notify account for all GOV.UK publishing apps, which helps to limit future infrastructure growth.

### Action Mailer

We will use [Action Mailer][action-mailer] to generate the individual emails to send to notify:

   - Using Action Mailer to process email is the recommended approach for Rails apps
   - Action Mailer comes with in-built support for testing and sending email asynchronously

Although Notify provides a [templating feature][notify-features], we will use a single, generic template for all 'GOV.UK Publishing' notifications, with recipient, subject and body parameters; the body supports a limited form of Markdown. Using Action Mailer to handle the generation of emails means we limit our reliance on Notify templates; we can make most of our changes in code, with the usual benefits of testing, faster debugging and version control.

Notify only supports a [single recipient for each email][notify-gem-send-email], so we will need to generate and send separate emails for each recipient. Although this requires more API calls, it's easier to reason about failure for individual emails.

Notify will reject an email when a recipient is not in a specific list, if one has been setup. In order to retain end-to-end email functionality but avoid emailing users outside of production, we will use an [Action Mailer Interceptor][action-mailer-interceptor] to redirect emails to a Google Group in integration and staging environments. The Google Group(s) will act as a dumping ground for viewing the emails that have been generated, which enables us to check they appear correctly in text and HTML forms.

### Active Job

We will use [Active Job][active-job] in combination with [Action Mailer][action-mailer] to send emails asynchronously.

   - This means any delay in calling the Notify APIs does not impact on the user request
   - We can use the [retry feature][active-job-retry] of Active Job to cope with transient failures from Notify

Action Mailer integrates with Active Job instead of specific queueing systems, and recent [improvements to the Active Job framework][active-job-improvements] also make it a viable for other background jobs, so we can avoid having to use a mixture of frameworks.

Active Job does not handle asynchronous processing directly and instead delegates to a queueing provider. Initially, we will use [Sidekiq][sidekiq], which is already common on GOV.UK and one of the [in-built queueing adapters][active-job-sidekiq] provided with Active Job.

### Sidekiq

We will use [Sidekiq][sidekiq] in order to handle the actual processing of background jobs. Sidekiq is already used by other apps on GOV.UK for background job processing, to the extent that including it in apps is managed by a [wrapper gem][sidekiq-govuk].

In order to avoid [duplicate retry behaviour][active-job-sidekiq-retry], we will disable Sidekiq retries and rely solely on the retry behaviour of Active Job. When a failure occurs, the job is marked as 'processed' by Sidekiq and any retry manifests as a newly enqueued job; when the retries are exhausted, the exception will propagate to Sidekiq and the job will be marked as 'dead'. Normally, the job would be marked as 'failed' by Sidekiq and requeued; this means we lose visibility on the number of retries.

We already use [Raven] to report errors to Sentry, which automatically [integrates with Sidekiq][sidekiq-sentry]. Note that Raven also [integrates with Active Job][raven-active-job], but this is disabled when Sidekiq is present. Active Job catches exceptions as part of its retry behaviour, so an error will only get reported to Sentry when the exception is not handled by Active Job, or the retries for an exception we do handle are exhausted. We already [export Sidekiq metrics to Graphite][sidekiq-grafana].


## Status

Accepted

## Consequences

Previously we used Sidekiq to implement a [background worker for scheduling][consequences-sidekiq-worker]. We will rewrite this to use the Active Job framework. Since Active Job does not retry jobs by default, we no longer need to [add middleware to facilitate aborting the job][consequences-sidekiq-abort].

Using the retry feature of Active Job instead of Sidekiq means we will lose visibility of the number of failures in the Sidekiq dashboard and in the metrics exported to Graphite. However, we will retain visibility of jobs that have totally failed.

The body content of our emails is limited by the Markdown subset implemented by Notify. If a design calls for specific formatting, we will need to liaise with the Notify team to implement something that works for text and HTML alternatives.

Each email needs to be sent as an individual request to Notify, which doesn't support bulk recipients. This makes it easier to reason about failure/retry of individual emails, but involves more external API calls.
