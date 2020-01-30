# User Permissions

There are a number of permissions that can be applied to a user in Content
Publisher. In integration, staging and production environments these are
managed through [signon][]. In a local environment permission changes can be
made through the Rails console, for example:

```
irb(main):001:0> user = User.first
irb(main):002:0> user.permissions << User::ACCESS_LIMIT_OVERRIDE_PERMISSION
irb(main):003:0> user.save
```

## Permissions and their affects

All permissions used by Content Publisher are set as constants on the
[User model][].

### `access_limit_override`

The access limit feature in Content Publisher allows a publisher to forbid
users outside of their organisation from accessing a document prior to its
publishing. A user with the `access_limit_override` permission will be
granted access to all documents no matter what organisation they belong to.

### `debug`

The `debug` permission is intended for Content Publisher developers as a means
to view diagnostic information within the application. This is currently
limited to being able to view the edits made in each revision of a document.

### `managing_editor`

The `managing_editor` permission acts as a role that is given to users who
are the managing editors for their department. Having this permission
enables users to manage the withdrawing of content and the ability to
distinguish whether content is applicable for [history mode][].

### `manage_live_history_mode`

When content is on GOV.UK and in [history mode][] it can no longer have new
drafts created, and it can no longer be withdrawn. However, users that have the
`manage_live_history_mode` permission are granted the ability to perform these
actions.

### `pre_release_features`

Content Publisher makes use of a simple feature flag pattern where any features
that are not yet releasable are [wrapped in permission
conditionals][feature-flag-add]. This enables incomplete features to be merged
into the codebase and deployed without them being available to all users. When
the feature is ready these conditionals [are then removed][feature-flag-removal].
Users who hold the `pre_release_features` permission will have access to
these features; this permission is typically only granted to members of the
team developing Content Publisher.

[signon]: https://docs.publishing.service.gov.uk/manual/manage-sign-on-accounts.html
[User model]: https://github.com/alphagov/content-publisher/blob/master/app/models/user.rb
[history mode]: ./history-mode.md
[feature-flag-add]: https://github.com/alphagov/content-publisher/commit/afea66e11f6b8ca0d4db39856add1b2709753cca
[feature-flag-removal]: https://github.com/alphagov/content-publisher/commit/a7667cb5e16abb5ca24d7483851b81c04d224027
