# History mode

## What is history mode?

History mode is a feature on GOV.UK that was introduced when the 2010-2015 coalition government made way for the 2015-present Conservative government. It is used as a means to label content that is on GOV.UK and doesn’t reflect the policies of the current government. It is intended as a means to keep historical content on GOV.UK while informing users that it may not represent current policies.

Two factors determine whether content is in history mode: whether the content is deemed political and whether the government the content is associated with is current or not.

## When is content in history mode?

Content is considered to be "in history mode" if it is flagged as being political and it is associated with a government that is not the current government.

These characteristics can apply to documents of any state in Content Publisher, which therefore means all states of documents can be in history mode.

## When is content associated with a government?

A government is [determined automatically](https://github.com/alphagov/content-publisher/blob/5246e7ffa8a33d3b607531ed66829e4dba5cc5ec/app/services/publish_service.rb#L33) for a piece of content when it has a date to represent when it was first published on GOV.UK. A user cannot select a government manually, their only controls over this are timing when the content is published or backdating it.

Thus all content in a live state (published, published but needs 2i review, withdrawn, removed) will have an association with a government as these will all have a date indicating when they were published on GOV.UK.

For draft states (draft, submitted for review, scheduled) content is [associated with a government](https://github.com/alphagov/content-publisher/blob/5246e7ffa8a33d3b607531ed66829e4dba5cc5ec/app/services/edit_edition_service.rb#L30) based on whether the content is [backdated](https://github.com/alphagov/content-publisher/blob/5246e7ffa8a33d3b607531ed66829e4dba5cc5ec/app/models/edition.rb#L139)) and whether it is a new edition of published content. For example:

- A first edition of a document that is not backdated will not be associated with a government until it is published
- A second edition of a document that is not backdated will be associated with the government from the publish date
- A backdated edition will be associated with the government at the time of the backdating

It's worth noting that backdating takes precedence over a publish date in determining which government.

## How is content defined as political?
Content can be defined as political. This is used as a shorthand way of saying that this content represents the policies of a particular government.

By default the [political status of content is determined automatically](https://github.com/alphagov/content-publisher/blob/5246e7ffa8a33d3b607531ed66829e4dba5cc5ec/app/services/edit_edition_service.rb#L25) whenever the content is edited. The following [criteria](https://github.com/alphagov/content-publisher/blob/5246e7ffa8a33d3b607531ed66829e4dba5cc5ec/lib/political_edition_identifier.rb#L16) is used to determine political status:

- What document type the content is
- Whether it is associated with an organisation that publishes content that mostly represent the policies of the current government
- Whether the content is tagged to a role appointment (we eventually hope to expand this to be whether the content is tagged to a minister of the respective government)

There is an ability to override whether content is defined as political. This is restricted to specific users. These users can specify content is political or not and the previously mentioned criteria will no longer have an affect.

## Who has the ability to change the attributes that affect history mode?

An intention behind history mode is to restrict the ability of publishers to make edits to content once a government has changed. This is to preserve content in the state it was at the point of a government change.

This is reflected by:

- Only Managing editors with the `MANAGE_LIVE_HISTORY_MODE` permission have the ability to withdraw, unwithdraw, or remove published content that is in history mode.
- Other users with the `MANAGE_LIVE_HISTORY_MODE` permission can create new editions of published content that is in history mode.
- [Managing editors](https://github.com/alphagov/content-publisher/blob/7ae279ca3e874e8e0d89cbefed601c1710f7aa7f/app/models/user.rb#L9) of organisations have the ability to override the political status of content

## How does history mode affect content in different states?

In Content Publisher content can have different statuses. What follows is a breakdown of these based on the effects of history mode.

### Draft

- When a draft is in history mode the previews on GOV.UK will show the banner of the associated government
- All users can submit for review, preview it, publish, schedule or delete draft

### Submitted for 2i review

Same as draft.

### Scheduled to publish

- Previews will show previous government banner
- All users can stop scheduled publishing and change date of publishing

### Published

- Live content on GOV.UK will show previous government banner
- Only users with the "manage_live_history_mode" permission can create a new edition, withdraw or remove content

### Published but needs 2i review

Same as published, however all users can approve the content.

### Withdrawn

- Only users with the "manage_live_history_mode" permission can change the public explanation
- Only users with the "manage_live_history_mode" permission can undo the withdrawal

### Removed

- Only users with the "manage_live_history_mode" permission can create a new edition

### Failed to publish

Same as draft.
