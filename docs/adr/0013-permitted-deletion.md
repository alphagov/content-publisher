# 13. Permitted Deletion

Date: 2019-07-24

## Context

[ADR 8: Restricted deletion][ADR-8] explained the decision that
[foreign key][foreign-keys] associations in the Content Publisher database
will all use the `restrict` constraint. At that point in time it was
identified that we do not have any use cases for deleting data from the Content
Publisher database.

Since then we have developed the access limit feature. This feature prevents
users who are not part of a particular organisation from viewing content. A
vulnerability in the access limit feature is that production data is
synchronised to an integration environment where the access controls
aren't as stringent, thus potentially allowing unauthorised users access to
sensitive content. To resolve this issue GOV.UK applications have taken the
approach of either removing or redacting data during the data sync process.

For Content Publisher to be consistent with other GOV.UK applications we had
to choose between redacting or removing data associated with an access limited
edition.

## Decision

We decided that data would be removed from Content Publisher during the
production to integration sync. This is significantly simpler than redacting
the data and less likely to require adaptation for the needs of particular
formats.

The approach taken to achieve this is to delete all data related to an
access limited edition that isn't shared with another edition. To allow
this we decided to [replace `restrict` constraints
in the editions table with `cascade` behaviour][editions-commit] that
automatically deletes associated records. A [similar approach was
applied to revisions][revisions-commit] to allow them, and associated data,
to be deleted when they are no longer associated with an edition.

## Status

Accepted

## Consequences

We no longer have a hard and fast rule that foreign key constraints should
always restrict deletion. Developers manipulating the structure of the database
now have to consider whether a change impacts data that can be access limited.
If this is the case, there must not be constraints that prevent deletion as
part of the data sync.

[ADR-8]: https://github.com/alphagov/content-publisher/blob/master/docs/adr/0008-restricted-deletion.md
[foreign-keys]: https://www.postgresql.org/docs/9.5/ddl-constraints.html#DDL-CONSTRAINTS-FK
[editions-commit]: https://github.com/alphagov/content-publisher/commit/126a40b51c5e44edca8c4effac568f12feeda8ba
[revisions-commit]: https://github.com/alphagov/content-publisher/commit/5fdc3355f10af1718d8a53b23117626689cdd576
