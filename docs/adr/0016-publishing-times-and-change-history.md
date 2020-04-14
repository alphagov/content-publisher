# 16. Publishing times and change history

Date: 2020-03-20

## Context

Content that is published on GOV.UK has metadata to indicate the history of
the content. This is comprised of a time to indicate when the first iteration of
that content was published (`first_published_at`), a time for when the content
was last changed in a meaningful way (`public_updated_at`) and a
change history which records a change note and the publishing time of each of
these meaningful changes. By convention, the first item in a change history of
GOV.UK content is provided by the publishing application without publisher
input. This item has a change note of "First published." and has the time the
content was initially published on GOV.UK.

To set these metadata fields Content Publisher has relied on the Publishing API
automatically setting the time fields and using it's
[ChangeNote][pub-api-change-note] model. This model stores a record for each
major change published on GOV.UK and can collate them to build a change
history. This meant that Content Publisher has not needed to store
`first_published_at`, `public_updated_at` or a full change history and has only
needed to store a change note for an edition.

We had concerns that continued usage of the Publishing API time and change
history system would lead to discrepancies when migrating content from Whitehall
to Content Publisher. This led to us doing a review of the system and problems,
where some relate to migration and others are broader.

### Problems identified

#### 1. Having accurate times for Whitehall migrated content

When content is migrated from Whitehall to Content Publisher we want all the
times associated with that content to remain the same. Whitehall complicates
this by passing two time values to represent the first publishing time: the
aforementioned `first_published_at` field and a deprecated time value,
`first_public_at`, which is used [preferentially to
`first_published_at`][first-public-at] when rendering the content. Content
Publisher does not populate the `first_public_at` field.


Some content items, notably older ones that pre-date Whitehall sending a
`first_published_at` value, can have different values for
each of these times - A consequence of these not matching is that migrated
content would show a different first publishing time.

#### 2. Migrating change notes from Whitehall

Whitehall doesn't make use of the [Publishing API ChangeNote][pub-api-change-note]
model to build a change history, instead Whitehall creates it's own change
history for content and includes it when updating content with the Publishing
API. This has a consequence that the data stored in ChangeNote models in
Publishing API for Whitehall content cannot be relied upon as there are no
guarantees of its accuracy. There is also not an expectation that this data is
accurate as many pieces of Whitehall content were created before the
ChangeNote model was introduced to Publishing API.

For Content Publisher to migrate change histories for Whitehall content it
would need to ensure the entire change history is in sync with the Publishing
API.

#### 3. Removing/editing change notes

It is a relatively common task that GOV.UK 2nd line support engineers are
[requested to remove or modify a change note][change-note-docs] for a published
piece of content. To resolve this in Whitehall a developer would modify a past
edition of a piece of content to either remove or amend the change note.

In Content Publisher it is not ideal to modify a past edition. An
[edition][adr9-core-concepts] represents a snapshot of the content as it was
published on GOV.UK and any edits invalidate the accuracy of this snapshot.

#### 4. Backdating content

The backdating feature in Content Publisher supports only backdating the first
edition of a piece of content and not subsequent ones as is allowed by
Whitehall. This is because the Publishing API does not have the means to change
the initial item in the change history for content and thus would cause a
change history that is inconsistent with the `first_published_at` time. This
has a consequence for publishers that if they make a mistake with backdating
or forget to backdate in Content Publisher then they cannot rectify this
without creating a new document or requesting support from developers.

### Approaches considered

#### 1. Correct Whitehall data in the Publishing API

We considered doing an audit and syncing exercise for times and change
histories from Whitehall to the Publishing API. This would involve either
doing a large data modification exercise or creating new endpoints
in the Publishing API that allow importing this data.

The positive of this approach was that it could mean Content Publisher
could continue to rely on the Publishing API for time and change history
management without needing this data stored in Content Publisher.

The negatives to this were that there would be no guarantees that this data
would remain accurate once the work was complete, as Whitehall continues to
operate; nor would it be easy to check whether data is still
accurate during migration as Content Publisher does not store it. This also
didn't allow any improvements in removing/editing change history or allowing
backdating past the first edition.

#### 2. Store times and change history in Content Publisher and sync them to Publishing API

We considered changing Content Publisher to be similar in approach to
Whitehall and be the canonical source of publishing times and change history.
Each time Content Publisher content is updated the Publishing API would be
sent the times and change history.

This approach offers a greater degree of control over data, which allows
Content Publisher to enhance the backdating feature and provide more support for
change history removal/editing. This also offers a higher degree of
compatibility with Whitehall for migrating content due to it being a similar
model.

This negative is that it increases Content Publisher's responsibilities
to storing time and change history. It also means that prior to publishing
content Content Publisher would need to update timestamps in the Publishing API
which adds an additional API call.

#### 3. Adapt Publishing API to support an altering change history

We considered modifying the Publishing API to allow the altering of change
histories. This would involve change notes having a particular id value that
could be used to identify them in requests.

As a positive, this allows each change note to be treated as a separate concept
to content and, compared to other approaches, allows a reduction in duplicate
data shared between different editions of content.

A negative of this is that it requires additional development and complexity
for the Publishing API with a potential migration needed for existing content.
It also presented a number of complications over whether change history would
be part of a draft/live workflow, since content already has this concern.

## Decision

We decided to take the approach of storing times and change history in Content
Publisher.

We felt that this was the most pragmatic approach as it didn't require
additional development to the Publishing API and was the most compatible with
Whitehall's approach to change history. The increased control this offered
was also consistent with a potential future feature of allowing change history
to be modified via a user interface.

We concluded that the recommended approach for change history in the Publishing
API was ultimately flawed and should be reconsidered as a recommendation. Our
concerns were:

- all publishing applications, with the exception of Specialist Publisher,
  use the Publishing API as a syncing target rather than a store of publishing
  history, which is a reversal from the unrealised intention that Publishing
  API is the canonical store for content and history;
- change history is the lone outlier as user visible data on GOV.UK that a
  publishing application cannot fix in case of any issues;
- the Publishing API ChangeNote model was designed to be append-only and
  is therefore incompatible with the ability to change the time that content
  is marked as first published (as the change history will disagree with this
  value) or to resolve any mistakes.

## Status

Accepted

## Consequences

Content Publisher will store all the information needed to present
`first_published_at`, `public_updated_at` and change history to the Publishing
API. In doing so Content Publisher will be considered the canonical source
of this data. This data will be reflected by non user editable data of
`first_published_at` on a Document model and `published_at` on an Edition model,
which reflects the time that Content Publisher published the content. In
addition to the existing `change_note` field on a MetadataRevision there
will also be a `change_history` field that stores a JSON representation of all
the previous change history entries for the content.

This `change_history` field will be used to store a collection of timestamps
with notes. These will not include the fixed "First published." change note as
this will automatically be appended to the start of a change history with a time
based on either the `first_published_at` or backdating value. It also
does not include the current change note of an edition because this does not
become an aspect of change history until the content is published and the
update type and publishing time are fixed. It was noted that having both
`change_note` and `change_history` fields risks confusion for developers,
however this seemed preferable to complicating the `change_history` field with
data that is not yet historical.

Initially the only means to edit items in a change history will be via a rake
task that developers can perform. This will provide a means to add, edit and
delete items. Eventually we may choose to build a Web UI to edit this.

We will expand the [IntegrityChecker][] system used by Content Publisher to
verify that the times and change history sent to the Publishing API match what
is already stored for Whitehall content. This will ensure that these remain
consistent through a migration.

The Publishing API had previously [deprecated][change-history-deprecation] the
`change_history` field in favour of using the `change_note` field. We will
remove this deprecation to reflect that using the `change_history` field is
still a valid approach that is in active use.

[pub-api-change-note]: https://github.com/alphagov/publishing-api/blob/master/doc/model.md#changenote
[first-public-at]: https://github.com/alphagov/government-frontend/blob/a800707ddafacfa9cea2a5ac0e8f9dfad4eed8d3/app/presenters/content_item/updatable.rb#L17-L19
[change-note-docs]: https://docs.publishing.service.gov.uk/manual/howto-remove-change-note-from-whitehall.html
[adr9-core-concepts]: https://github.com/alphagov/content-publisher/blob/481f4cb2af21918d115fe542601a101db622f9b5/docs/adr/0009-modelling-history.md#core-concepts
[IntegrityChecker]: https://github.com/alphagov/content-publisher/blob/5aa0e3bf6d6ed04c44166c15b1aa15e8ad1645fa/lib/whitehall_importer/integrity_checker.rb
[change-history-deprecation]: https://github.com/alphagov/publishing-api/pull/576/files
