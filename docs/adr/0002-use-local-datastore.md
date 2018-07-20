# 2: Use local datastore for publisher workflow

Date: 2018-07-20

## Context
We're building a new publishing architecture and MVP workflow in private beta. We have taken the decision to build this in a new application and therefore we need to decide how we use the publishing-api.

One of the goals of the migration effort from 2016 was to for all publishing applications to be clients of the publishing-api and this API would means that these applications would not need local datastores. This is written up in the [GOV.UK Platform Architecture Goals 2017-18+][goals]

[goals]: https://docs.google.com/document/d/1Oft4akc6dZfhhOjosNPbFpcLUOUjz7YG7QPcVZi8hww/edit#heading=h.5uytjxbfoe58

Since writing these goals we have built the specialist-publisher application using this pattern. The practicalities of using the pattern 

We are about to build another publishing-api client and we should now use the learnings we have from building specialist-publisher to ensure that the not using a local datastore is the best decision.

### Option 1: No local datastore
In this option we continue with the platform architecture goals.

#### Pros
+ Single source of truth - all data is in the publishing api
+ Multiple apps can edit the same content
+ Single implementation of scheduling and publishing logic
+ Single abstraction layer

#### Cons
- Effectively building an Active Resource layer
- Harder to resolve performance problems
- Current workflow is opinionated and may not match needs of content
- Validation can be difficult to explain to user
- Hard to deploy

### Option 2: Use a local datastore
#### Pros
+ It’s standard Rails so quick to build and easy to understand
+ Easy to test, testing over an API is not easy and slow
+ Easy to iterate workflow, changing the API workflow is much harder
+ Only final state of content can be put into publishing-api - some formats will need interim data which isn’t needed for publishing
+ No new features needed for meta data - notes, and other publisher info

#### Cons
- Syncing between local and publishing api
- Local data is hard to query by other applications
- Expanded Links
- Combination of local and publisher API workflows
- Hard to feedback to use on asynchronous API updates
- Content-Schema may not matching Rails validations causing unhelpful error messages

## Decision
We will use a local datastore which syncs to the publishing api.

## Status

Accepted

## Consequences
The problems we found when building and maintaining specialist-publisher have shown that the practicalities of not having a local datastore outweigh the architectural purity of a single datastore.

There will be problems in keeping the local datastore and the publishing API in sync in addition to the user experience problems of updating users on the results of asynchronous updates. However the speed and ease of development improvements should outweigh this.

