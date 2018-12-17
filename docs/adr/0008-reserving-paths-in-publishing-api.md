# 8. Reserving paths in Publishing API

Date: 2018-12-20

## Context

Content Publisher and Whitehall can both publish the same document types to
GOV.UK that use the same URL formats. This can lead to conflict scenarios where
a publishing in one application is blocked by a publishing in the other.

For example, if Whitehall has a document with a base path of
`/government/news/breaking-story` and Content Publisher also has a document
with a base path of `/government/news/breaking-story` only the first app can
publish to GOV.UK.

Both applications prevent a user from entering a base path themselves and
instead generate one based on a title. They currently both append numeric
suffixes to create unique base paths when a document within the application
is already using the base path.

While a document is in draft both Whitehall and Content Publisher change the
base path each time the title is edited. Once content is published Whitehall
maintains the base path even if the title is changed, Content Publisher
continues to change base path when title is edited on subsequent drafts. It
is not agreed yet whether Content Publisher should behave the same as Whitehall.

Publishing API is the authority on base paths. It has a concept of a
`PathReservation` which is an object that reserves a particular path for a
given application. Thus in the above example if Content Publisher had reserved
`/government/news/breaking-story` then Whitehall wouldn't be able to publish
content at that path even if it did so before Content Publisher.

A [MoSCoW](https://en.wikipedia.org/wiki/MoSCoW_method) breakdown of the
functionality required to resolve the conflict issues is defined as:

### Must

- have ability to generate a base path, from a given input, that is not used or
  reserved by other GOV.UK applications;\
  *because* publishers often can't define a documents slug so must rely
  on the system to generate a unique one.
- allow reserving a base path on GOV.UK publishing stack;\
  *because* we don't want to hinder publishing because of a base path
  conflict.

### Should

- have an approach to remove a reserved base path if it is no longer needed;\
  *because* Content Publisher generates base paths from a JavaScript change
  event and therefore a document could have assumed a number of base paths
  before the one it is eventually published with.
- allow multiple base paths to be reserved for a single document;\
  *because* a document could have different base paths for live and draft
  versions (and potentially want to maintain older ones for redirects).
- consider how Whitehall can reserve base paths;\
  *because* Whitehall publishing could be blocked by documents published by
  Content Publisher.
- produce the same base path if a user enters one title, changes it and then
  reverts back,\
  *because* it would be a poor user experience if having a title once made it
  unavailable to use again.

### Could

- allow Content Publisher to reserve base paths without a corresponding document
  being persisted in the database;\
  *because* there are unresolved concerns/debates about the point in the
  workflow that a document is created.

### Won't

- support resolving base path conflicts with a method more
  sophisticated than a numeric suffix;\
  *because* there are not decisions/recommendations on a nicer approach and
  these are therefore considered out of scope.
- provide means for the slug aspect of a base_path to be any place other than
  the end of a base_path (e.g. we support `/government/news/:slug` and not
  `/government/:slug/news`);\
  *because* only suffix slug base paths are currently used on GOV.UK;
- consider means that a new document can claim the base path of a document
  that has a "removed" state on Content Publisher;\
  *because* claiming old base paths is a niche feature that is complicated
  due to one document changing the state of another.

## Decision

Two new endpoints should be created in Publishing API:

1. POST `/paths`. This should take attributes of `base_path_prefix`, `title` and
  `publishing_app`. Given these attributes it will generate and return a base
   path that does not conflict  with content or existing reservations.
   Internally the Publishing API will create a `PathReservation`.
2. DELETE `/path(/*base_path)`. This will remove a `PathReservation` from
   Publishing API for a given `base_path` if the requesting publishing
   application is the one that reserved the path.

Content Publisher should call the POST endpoint to reserve paths and it should
maintain a record of the paths it has reserved. This would be stored on a
`ReservedPath` model (naming TBC but purposely distinct from `PathReservation`).
This would store `base_path_prefix`, `title`, `base_path`, and timestamps. This
model may also store some an id to associate the `ReservedPath` with a
particular session.

The `Document` model in Content Publisher would store an association to the
`ReservedPath` that is currently used - it would also be useful to store the one
the live version of the document is using. The lack of usage by a
`Document` is an indication that a `ReservedPath` is available for use or can
be un-reserved from the Publishing API (after a suitable time
period).

When a user makes changes to the title input on the edit content form a HTTP
request is sent to Content Publisher to generate a title. This should operate
as follows:

- The title and path prefix should be used to check whether there is
  an available `ReservedPath` available in Content Publisher database;
- If one is found it should be verified that the `ReservedPath` belongs to the
  corresponding document (or session);
- If there is not one found the Publishing API should be called to generate
  a base path, this should then be stored in the Content Publisher database.

When a user saves the content of a Content Publisher document it should do the
following:

- Check whether the title has changed since the document was last saved, if not
  don't proceed further;
- Check whether a `reserved_path_id` was submitted and if there is an available
  `ReservedPath` that matches the document title and path prefix.
- If there is not then synchronously call Publishing API to generate a base
  path, this base_path should be stored as a `ReservedPath` and associated
  with the document.
- If there was a previous path reservation and is not associated with a live
  edition of the document then this can be discarded and removed from
  Publishing API.

Periodically a background task should run in Content Publisher to clean up any
`ReservedPath` objects that are not use by a document and are suitably old
(initial suggestion is 6 hours). This task should remove the delete the
`PathReservation` on the Publishing API and then delete the record in Content
Publisher database.

The suggestion for Whitehall is to perform a simpler version of path
reservation to reflect the fact that Whitehall only sets a base path at the
point of saving a document rather than whenever the title input changes. The
code for slug generation in Whitehall would be updated to post to the Publishing
API `/paths` endpoint so that base paths unique from Content Publisher could be
created.

## Status

Proposed

## Consequences

Publishing API would have a new feature/responsibility in generating paths for
applications. This may be considered the optimal way for an application to
generate a path (as it is at the centre of the GOV.UK publishing platform),
thus should be available for other applications to use and represent best
practices.

This proposal only considers that a base path can be created in the Publishing
API from the combination of a prefix and a title. This means that it is not
supported for the slug part of a path to occur in the middle of it - eg. if we
wanted to use a path format of `/prefix/:slug/suffix` it would not be supported.
If we were to decide this functionality was needed the Publishing API endpoint
would need to support a more complicated input of URI template rather than a
path prefix.

The suggestion to add a background job to Content Publisher would be the first
such job and would likely add an additional dependency of
[Redis](https://redis.io/) to the application.

Saving a draft edition in Whitehall would require an additional HTTP request
to Publishing API to create the path (stored in Whitehall as a slug). The
effects of this would likely be negligible as Whitehall already does a number
of HTTP requests in the process of saving.
