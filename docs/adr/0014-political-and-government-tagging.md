# 14. Political and Government Tagging

Date: 2019-12-19

## Context

In [ADR 6](0006-tagging-governments.md) we discussed our decision to defer
the tagging of governments and political status to content. In December 2019
the political climate determined that we would need to implement this as it
was expected that content published through Content Publisher would have to be
able to enter [history mode](../history-mode.md).

In order for content to be in history mode it needs to be associated with a
government that is no longer the current one and the content itself be flagged
as political. This tagging broadly means that the content represents the
policies of the government it is associated with.

The business rules behind this feature dictate that the political status of
content is determined dynamically based on attributes and associations of the
content. The government is determined based on the time the content is first
published or backdated to.

## Decision

To implement this feature we decided to add a [service][edit-edition-service]
that runs each time content is edited which can determine whether the content
is political or not. If the content has been published or is backdated it can
also determine the government. This data is stored in the editions database
table. As this value is dynamically calculated only the current value is
stored as it is not considered an aspect of the publications history.

The political value for the content can be overwritten by a publisher. This
value is known as `editor_political` and supersedes the value stored on an
edition, which is known as `system_political`. As this data is set by a
publisher it is considered part of a revision of a document and is stored
for prosperity.

When content has not been published or backdated it is not associated with a
government. At the point of content being published the current time is used
to determine the government.

When sent to the Publishing API, these fields are represented in the form of
a boolean attribute for political and an edition link for the government.
In the time since ADR 6 governments have been added to the Publishing API
which means that content associated with a government no longer needs to be
republished when the government is no longer current.

## Status

Accepted

## Consequences

Content Publisher now has an approach for determining dynamic properties of
content automatically based on user edits.

Content Publisher will often have to update the preview of content just before
publishing to set the correct government. This increases the tasks done at
the point of publishing and, therefore, increases the risk of a timeout.

[edit-edition-service]: https://github.com/alphagov/content-publisher/blob/265226bc0c613d2294b4cb0d33d2f26cfcf54811/app/services/edit_edition_service.rb
