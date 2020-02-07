# Removing or removing and redirecting a document

We need to allow users to remove content from GOV.UK. Currently, a user can't
remove a document from the UI so a developer needs to run a rake task to
achieve this.

Removed content returns a 410 gone page to the user. If an explanatory note or
a alternative path have been provided, they will be displayed in the body of
the page.

Removed and redirected content redirects users to another page on GOV.UK

Environment variables are being used to pass parameters to the rake tasks.

## Removing documents

Required parameters:

- content_id

Optional parameters:

- LOCALE (set to "en" by default)
- NOTE
- URL

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

```
rake remove:redirect['a-content-id'] URL='/redirect-to-here'
```
