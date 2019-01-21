# 7. Minimal Model

Date: 2019-01-21

## Context

We currently have several classes that we think of as models.

   * ActiveRecord classes that reflect persisted data in the database. These are conventionally found in `app/models`.
      * Example: `Document`
   * Plain Ruby classes that reflect readonly data stored in configuration files. These currently have no place to live :-(.
      * Example: `DocumentType`

We also have other classes that resemble models, but aren't e.g.

   * `DocumentUrl` is not a class we think of as a model e.g. because it has no public attributes
   * `UserFacingState` is not a class we think of as a model e.g. because its instances have no unique ID

We would like to make it clear which classes belong in `app/models`.

## Decision

We should treat a class as a model if it has the following properties.

   * **The name of the class is a noun that represents a domain concept**
      * Example: a `Document` represents all revisions of a piece of content, etc.
      * Guideline: it should be difficult to rename the class to a verb
      * Guideline: the class should be documented in the README nomenclature
   * **Instances of the class have multiple attributes that encapsulate it**
      * Example: a `DocumentType` encapsulates publishing metadata, tags, etc.
      * Guideline: The attributes should be public and required in our code
   * **Instances of the class should have a unique identifier attribute**
      * Example: each `Document` has a unique `id` assigned by the database
      * Example: each `DocumentType` has a unique `id` in its config file
   * **Instances of the class support mass-assignment of their attributes**
      * Example: a `Document` supports assignment as an ActiveRecord model
      * Example: a `DocumentType` supports assignment on initialize (readonly)


## Status

Accepted

## Consequences

We should move `DocumentType` and `Supertype` into the `app/models` directory.

Any classes in `app/models` that do not have the above properties should be moved elsewhere.
