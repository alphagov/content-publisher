# 8. Restricted Deletion

Date: 2019-01-24

## Context

We use foreign keys to help enforce database integrity e.g.

```
# ensure creator_id on a document matches a row in the users table
# when we try to delete a user, raise an error if its the creator of a document
add_foreign_key "documents", "users", column: "creator_id", on_delete: :restrict
```

There are other `on_delete` behaviours instead of `restrict`.

```
# when we delete a user, set creator_id to NULL on all of its documents
add_foreign_key "documents", "users", column: "creator_id", on_delete: :nullify

# when we delete a user, also delete all of its document
add_foreign_key "documents", "users", column: "creator_id", on_delete: :cascade
```

Different options are appropriate depending on the foreign key.

   * `restrict` is a good choice in a child/parent scenario, where deleting a child should be restricted if it would make the parent invalid. For example, we should not be able to delete an ActiveStorage blob if its parent image still exists.
   * `nullify` works well if the relationship is optional. For example, our code doesn't currently require a document to have a creator, so it might be reasonable to `creator_id` on document to NULL if we delete a user for some reason.
   * `cascade` is a good choice in a parent/child scenario, where it makes sense to delete the child when we delete the parent. For example, if we delete a document for some reason, it also makes sense to delete the editions.

## Decision

Currently, we don't have any real-world scenarios for deleting stuff from the database. Therefore, we should do the simplest thing and `restrict` on all foreign key delete actions. `restrict` is actually the default, but we should continue to specify it explicitly to indicate a conscious decision.


## Status

Accepted

## Consequences

Restricting all foreign key deletions will make it difficult to delete anything. For example, we might be required to delete a user record in order to remove their personal data. We intend to revisit this decision if it becomes a pain point.

One situation where we may want to delete data is in our development environments. This can also be achieved by resetting the database - we should avoid making deletion more permissive in production for the convenience of devlopment.
