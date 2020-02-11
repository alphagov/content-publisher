# Removing or removing and redirecting a document

We need to allow users to remove content from GOV.UK. Currently, a user can't
remove a document from the UI so a developer needs to run a rake task to
achieve this.

Removed content returns a 410 gone page to the user. If an explanatory note or
a alternative path have been provided, they will be displayed in the body of
the page.

Removed and redirected content redirects users to another page on GOV.UK

Environment variables are being used to pass parameters to the rake tasks.

When calling these tasks the USER_EMAIL variable should be passed in with your
email address, for example:
`rake remove:gone['a-content-id'] USER_EMAIL=me@example.com`. This is so
the change can be associated with you, the developer that performed the task,
and attributed correctly in the document history.

## Removing documents

Required parameters:

- content_id

Optional parameters:

- LOCALE (set to "en" by default)
- NOTE
- URL
- USER_EMAIL

```
rake remove:gone['a-content-id']
```

## Redirect removed documents to another page on GOV.UK

Required parameters:

- content_id
- URL

Optional parameters:

- LOCALE (set to "en" by default)
- NOTE
- USER_EMAIL

```
rake remove:redirect['a-content-id'] URL='/redirect-to-here'
```
