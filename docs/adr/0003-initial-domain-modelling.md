# 3. Initial Domain Modelling

Date: 2018-07-23

## Context

Content Publisher is a new publishing application for GOV.UK that has the
ambition to eventually replace existing publishing applications such as
Whitehall, Specialist Publisher and/or Mainstream Publisher (exact scope of
this is to be determined). This ADR aims to document the considerations and
decisions made initially in [modelling the domain][domain-model] for this
application at the start of the project.

We aimed that the new model would enable us to:

- be compatible with GOV.UK's publishing pipeline
- model data that is stored in existing publishing applications, so it could be
  a migration destination
- try to avoid some of the problems we had identified in the modelling of
  existing publishing applications

### Approach to modelling

In modelling we considered whether we should:

1) Take a light touch to modelling the domain and evolve it as we learn more
2) Map out all of the known concepts from multiple publishing applications and
   model the system as a whole

Option 1 would allow us to initially develop faster as less time would be
spent researching and agreeing on concepts, however it could be at the expense
of the cohesiveness of the model. Option 2 risks building rules based off
assumptions that may not be correct or may change rapidly as the application
evolves.

### Modelling different localisations of content

We considered that there were two different approaches for localisations of
content in GOV.UK publishing:

1) Publishing API and Mainstream publisher consider different localisations
   to be different documents (with a common id) and can be published/edited
   separately
2) Whitehall model consider the localisations of a piece of content to be part
   of the same document, with each change to a localisation reflected in a
   shared history

The Whitehall model has the advantage that data can be shared between the
primary locale with translations, but has the disadvantage that a particular
locale of a document has a history that is associated with a wider range of
pages.

It is relatively simple to adapt the content of Whitehall to the model used by
Mainstream publisher, however it would not be simple to adapt the Mainstream
model to a Whitehall one as the document histories are not consistent.

### Modelling different document types

The expectation is that Content Publisher will support a wide variety of
document types, thus we want to choose a scalable approach to modelling them
so that the logic for them does not become unwieldy.

The approaches we considered were:

1) Whitehall/Mainstream Publisher approach of using inheritance
2) Publishing API approach of using a single model that can store schemaless
   data

Option 1 offers a more explicit means of defining the various document types
and characteristics. However it does so at the expense of greatly increasing
the number of models to be considered as part of the domain. We felt that in
our existing publishing applications that the burden of modelling the document
type as a core domain concept made the models difficult to understand.

[domain-model]: https://en.wikipedia.org/wiki/Domain_model

## Decision

We decided that:

- We will take a light touch to modelling within the application and evolve
  it as we learn more about the requirements of the application. As we feel
  we are insufficiently informed of the needs to model further.
- We have decided names for the following concepts:
  - Document: A piece of content in a particular locale that can have many
    versions.
  - Revision: A particular edit of a piece of content, represents a document
    at a specific point in time.
  - Edition: A particular revision that was published to GOV.UK or is the
    most current draft piece of content.
- We have decided not to name the following concepts:
  - The association between all documents that share the same `content_id` and
    have different locales. There doesn't appear to be a name for this in
    GOV.UK currently.
  - Data that is shared between revisions of documents in different locales. We
    don't know whether this will actually be necessary and will re-consider it
    if and when it becomes necessary.
- We will model content in different localisations as distinct documents, in
  a manner consistent with Publishing API and inconsistent with Whitehall.
- We will store document type specific data within a particular Revision via
  schemaless data (JSON) rather than modelling each document type as a domain
  object

## Status

Accepted

## Consequences

By taking a light touch to modelling now we will need to be cautious in how we
evolve it and/or be prepared to take time out to re-model should it become
unwieldy.

By taking the approach to modelling localisations in a manner consistent with
Mainstream publisher instead of Whitehall we risk in the short term creating
problems with users accustomed to a different way of working. It does however
mean that this will be consistent with the Publishing API which improves its
consistency with the whole GOV.UK stack.

By modelling document types within a single concept (Revision) we risk a lack
of enforced consistency between content of the same document type due to the
lack of schema.
