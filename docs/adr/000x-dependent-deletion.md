# X. Dependent Deletion

Date: 2019-01-20

## Context

Our database has a variety of inter-related tables. When we delete something from the database, we can use a couple of methods to help preserve the integrity of the remaining data: *foreign key actions* and *ActiveRecord dependencies*.

Both of these methods can leave behind unused records: foreign key actions don't propagate across join tables; and a chain of ActiveRecord `dependent: :destroy` callbacks can fail halfway through (the code is not atomic).

### Foreign Key Actions

At the database level, we can make use of foreign keys to help maintain integrity between related tables e.g.

```
# ensure creator_id on a document matches a row in the users table
# when we delete a user, unset creator_id on its documents (if any)
add_foreign_key "documents", "users", column: "creator_id", on_delete: :nullify
```

```
# ensure edition_id on a revision matches a row in the editions table
# when we delete an edition, also delete all of its revisions
add_foreign_key "revisions", "editions", column: "edition_id", on_delete: :cascade
```

```
# ensure current_revision_id on an edition matches a row in the revisions table
# when we delete a revision, error if its the current one for an edition
add_foreign_key "edition", "revision", column: "current_revision_id", on_delete: :restrict
```

Note these examples are for illustration only - they may not reflect the current schema of the app.

### ActiveRecord Callbacks

At the application level, we can make use of the ActiveRecord `dependent` callbacks in each of the models e.g.

```
# document.rb
# when we delete a document, run a DELETE on its timeline entries (fast)
has_many :timeline_entries, dependent: :delete_all
```

```
# document.rb
# when we delete a document, invoke #destroy on each of its images (slow)
has_many :images, dependent: :destroy
```

```
# document.rb
has_many :editions, dependent: :restrict_with_exception
```

Using `dependent: :destroy` is a easy way to delete a tree of records, but is not atomic if an exception occurs.

## Decision

We currently have no production use-case to delete anything in Content Publisher. This is sometimes necessary in development, but does not justify maintaining a bunch of `dependent` callbacks in production code.

1. We will not use ActiveRecord `dependent` callbacks until we have a use-case for them.

2. We will adopt a policy for foreign key actions on deletion, with the following guidelines:

   * **Restrict deletion of a *more important* thing by a *less important* thing**
      * Example: deleting a *revision* should not delete its *edition*
      * Example: deleting a *lead image* should not delete its *revision*
   * **Cascade deletion of a *less important* thing by a *more important* thing**
      * Example: deleting an *document* should delete its *timeline entries*
      * Example: deleting an *edition* should delete its *edition_revisions* (join table)
      * Exception: deleting a *document* should not delete its *editions* (see below)
   * **Nullify on deletion of something that's optional in the code**
      * Example: deleting a *user* can nullify *creator_id* on its *document*

The safest default would be to restrict deletion in all cases, but this would also make it very hard to delete anything and we recognise this may sometimes be necessary, hence the additional rules for cascade and nullify deletions.

One case where we should still restrict is when we delete a document that still has editions; we feel this is a case where we specifically want to make it harder to delete the related data, as a document is such an important thing.

## Status

Accepted

## Consequences

Disable the RuboCop cop that enforces the use of `dependent` callbacks.

Remove all uses of ActiveRecord `dependent` callbacks.

Ensure our foreign key constraints comply with the above policy.
