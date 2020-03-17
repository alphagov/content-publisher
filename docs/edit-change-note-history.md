# Editing a document's change history

Sometimes publishers will need to edit the historic change notes for a document.  Currently, a user cannot do this using the UI so a developer needs to run a rake task to achieve this.

To alter a document's change history **the current edition must be in an editable state**.  For a published edition, a new edition must be created through the UI.  Once the change history has been edited, the document can then be republished (e.g. as a minor change, to prevent any further change notes being added to the history).

When calling these tasks the USER_EMAIL variable should be passed in with your email address, for example:

```
rake change_history:delete['a-content-id','a-change-note-id'] USER_EMAIL='me@example.com'
```

This is so the change can be associated with you, the developer that performed the task, and attributed correctly in the document history.

In addition, an optional LOCALE variable can be supplied, for example:

```
rake change_history:delete['a-content-id','a-change-note-id'] USER_EMAIL='me@example.com' LOCALE='cy'
```

If omitted, LOCALE defaults to "en".

## Viewing all change notes for a document
Required parameters:
- content_id

Optional parameters:
- LOCALE

```
rake change_history:show['a-content-id']
```

## Deleting a change note
The document must have an editable current edition.

Required parameters:
- content_id
- change_history_id (can be retrieved using the 'show' task)

Optional parameters:
- LOCALE
- USER_EMAIL

```
rake change_history:delete['a-content-id','a-change-history-id']
```

## Editing a change note
The document must have an editable current edition.

Required parameters:
- content_id
- change_history_id (can be retrieved using the 'show' task)
- NOTE

Optional parameters:
- LOCALE
- USER_EMAIL

```
rake change_history:edit['a-content-id','a-change-history-id'] NOTE='Made some change to this document.'
```

## Adding a change note
The document must have an editable current edition.

Required parameters:
- content_id
- TIMESTAMP
- NOTE

Optional parameters:
- LOCALE
- USER_EMAIL

```
rake change_history:add['a-content-id'] TIMESTAMP='2020-01-02 09:30' NOTE='Added new statistics.'
```
