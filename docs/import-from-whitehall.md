# Importing documents from Whitehall to Content Publisher

There are three ways to import documents from Whitehall:
- [a single document](#single-document-import)
- [multiple documents](#multiple-document-import)
- [documents of a specific type or subtypes from a single publishing organisation](#import-documents-of-a-specific-type-and-subtypes-from-a-single-publishing-organisation)

## Running an import

### Single document import

This will import a single document and all its editions from Whitehall into Content Publisher.

```
rake import:whitehall_document[1234]
```

Where `1234` is the Whitehall document ID.  After running the rake task, a URL will be printed to the console which allows the status of import to be examined.

Note that the ID in Whitehall's internal URLs is the edition number (e.g. for `/government/admin/publications/1034451` the edition is `1034451`).  The document ID can be obtained on a Whitehall Rails console, for example:

```
irb> URI.parse("https://whitehall-admin.integration.publishing.service.gov.uk/government/admin/publications/1038279").path.split("/")[4].then { |id| Edition.find(id).document_id }
=> 412144
```

### Multiple document import

To import a number of documents and all their editions from Whitehall into Content Publisher.

```
rake import:whitehall_documents["1234 5678"]
```

Where `"1234 5678"` is a space-separated list of Whitehall document ids.  As with [a single document import](#single-document-import), after running the rake task, a URL will be printed to the console which allows the status of each imported document to be examined.

This type of import is useful for re-importing a list of specific documents, without having to import them individually, and when testing previously failed documents imports for de-bugging purposes.

### Import documents of a specific type and subtypes from a single publishing organisation

To import a single document type (e.g. news articles) from a single publisher (e.g. NDA):

```
rake import:whitehall_migration["nuclear-decommissioning-authority","news_article"]
```

To import multiple document subtypes (e.g. news stories and press releases) from a single publisher (e.g. NDA):

```
rake import:whitehall_migration["nuclear-decommissioning-authority","news_article","news_story,press_release"]
```

There is no limit to the number of subtypes (additional values are added comma separated).

It is also possible to import a single document subtype (e.g. press releases) from a single publisher (e.g. NDA):

```
rake import:whitehall_migration["nuclear-decommissioning-authority","news_article","press_release"]
```

After running the rake task, a URL will be printed to the console which allows the status of import to be examined.

## Running a migration locally using govuk-docker

Using [govuk-docker](https://github.com/alphagov/govuk-docker), you can run an import locally without needing to replicate data.  In order to do this, you will need to override the [Plek](https://github.com/alphagov/plek) URL for Whitehall and Publishing API to point to integration.  Additionally, you will require [bearer tokens](#getting-bearer-tokens).

Outside the GDS office, you must be connected to the GDS Developer VPN.  Inside the GDS office, you must be connected to the Brattain network (not GovWifi).  This is due to IP address restrictions on the applications that will be connected to.

### Getting bearer tokens

Tokens can be obtained by creating a new API user in Signon.  These allow access to the relevant remote applications without needing to enter a username and password.

1. Navigate to https://signon.integration.publishing.service.gov.uk/api_users
1. Click 'Create API user'
1. Enter a name (e.g. your name followed by 'Whitehall Import to Content Publisher Migration Testing') and an email address.  You will not be able to use your `digital.cabinet-office.gov.uk` email address as it will already exist.  However, do identify yourself - something like `<first_name>.<last_name>@alphagov.uk` is fine.
1. Once the user is created, click 'Add application token'
1. Select 'Whitehall', then add the 'Export data' permission
1. Copy the Whitehall token - you will not be able to access this again
1. Click 'Add application token' again
1. Select 'Publishing API'
1. Copy the Publishing API token - you will not be able to access this again

These tokens can then be set as environment variables:

```
export whitehall_bearer_token=<>
export publishing_api_bearer_token=<>
```

Replace `<>` with the bearer tokens you have previously obtained.

### Overriding Plek URLs

By default, Plek will point to your local development environment when running rake tasks in govuk-docker.  Therefore, you will need to override the Plek URLs.

E.g., for integration:

```
export publishing_api_url=https://publishing-api.blue.integration.govuk.digital
export whitehall_url=https://whitehall-admin.integration.publishing.service.gov.uk
```

These environment variables will be passed into govuk-docker in later steps.

### Setting up Sidekiq

In order to run a migration locally, Sidekiq must be running when the rake tasks are executed.  As jobs are run independently of the rake task, Plek overrides and bearer tokens are also required here.

```
govuk-docker run -e PLEK_SERVICE_PUBLISHING_API_URI=$publishing_api_url -e PUBLISHING_API_BEARER_TOKEN=$publishing_api_bearer_token -e PLEK_SERVICE_WHITEHALL_ADMIN_URI=$whitehall_url -e WHITEHALL_BEARER_TOKEN=$whitehall_bearer_token content-publisher-worker bundle exec sidekiq -C config/sidekiq.yml
```

### Running a migration

Either a single document or multiple document import can be run, as detailed in previous sections.

For example:

```
govuk-docker run -e PLEK_SERVICE_PUBLISHING_API_URI=$publishing_api_url -e PUBLISHING_API_BEARER_TOKEN=$publishing_api_bearer_token -e PLEK_SERVICE_PUBLISHING_API_URI=$publishing_api_url -e PLEK_SERVICE_WHITEHALL_ADMIN_URI=$whitehall_url -e WHITEHALL_BEARER_TOKEN=$whitehall_bearer_token content-publisher-lite bundle exec rake import:whitehall_migration["nuclear-decommissioning-authority","news_article"]
```

In order to access the URL printed at the end of the rake task, the Content Publisher application will need to be running locally:

```
govuk-docker up content-publisher-app
```

### Accessing a Rails console

You may wish to open a Rails console that allows you to perform tasks on Whitehall documents (e.g. unlock or lock a document in order to test the import task multiple times).  Information about locking documents can be found in [Whitehall's documentation](https://github.com/alphagov/whitehall/blob/master/docs/migration_to_content_publisher/locked-documents.md).

```
govuk-docker run -e PLEK_SERVICE_PUBLISHING_API_URI=$publishing_api_url -e PUBLISHING_API_BEARER_TOKEN=$publishing_api_bearer_token -e PLEK_SERVICE_WHITEHALL_ADMIN_URI=$whitehall_url -e WHITEHALL_BEARER_TOKEN=$whitehall_bearer_token content-publisher-lite rails c
```

To unlock a document you will need the Whitehall document ID.  Type the following into a Content Publisher Rails console:

```
require "gds_api/whitehall_export"
GdsApi.whitehall_export.unlock_document(1234)
```

To unlock all documents you have imported (useful when testing and comparing documents) type the following into a Content Publisher Rails console:

```
require "gds_api/whitehall_export"
WhitehallMigration::DocumentImport.pluck(:whitehall_document_id).uniq.each { |id| GdsApi.whitehall_export.unlock_document(id) }
```
