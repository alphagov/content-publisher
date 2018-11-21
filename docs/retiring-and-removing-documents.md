# Retiring and removing documents

We need to allow users to unpublish content from GOV.UK. In Content Publisher we are replacing
unpublish terminology with "retired" and "removed".

Retired content is still displayed on GOV.UK, but there is an explanation box on the page that describes
why the content is out of date.

Removed content returns a 410 gone page to the user. If an explanatory note or a alternative path have been provided,
they will be displayed in the body of the page.

Removed and redirected content redirects users to another page on GOV.UK

Environment variables are being used to pass parameters to the rake tasks.

## Retiring documents

Required parameters:

- CONTENT_ID
- NOTE

Optional parameters:

- LOCALE (set to "en" by default)

```
rake unpublish:retire_document CONTENT_ID='a-content-id' NOTE='A note'
```

## Removing documents

Required parameters:

- CONTENT_ID

Optional parameters:

- LOCALE (set to "en" by default)
- NOTE
- NEW_PATH

```
rake unpublish:remove_document CONTENT_ID='a-content-id'
```

## Redirect removed documents to another page on GOV.UK

Required parameters:

- CONTENT_ID
- NEW_PATH

Optional parameters:

- LOCALE (set to "en" by default)
- NOTE

```
rake unpublish:remove_document CONTENT_ID='a-content-id' NEW_PATH='/redirect-to-here'
```
