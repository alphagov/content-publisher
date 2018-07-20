# 2: Use local datastore for publisher workflow

Date: 2018-07-20

## Context
We're building a new publishing architecture and MVP workflow in private beta. We have taken the decision to build this in a new application and therefore we need to decide how we use the Publishing API.

One of the goals of the migration effort from 2016 was to for all publishing applications to be clients of the [Publishing API] and this API would means that these applications would not need local datastores. This is written up in the [GOV.UK Platform Architecture Goals 2017-18+][goals]

[goals]: https://docs.google.com/document/d/1Oft4akc6dZfhhOjosNPbFpcLUOUjz7YG7QPcVZi8hww/edit#heading=h.5uytjxbfoe58

Since writing these goals we have built the specialist-publisher application using this pattern. The difficulties of building Rails application this way have led us to reconsider this approach.

We are about to build another [Publishing API] client and we should now use the learnings we have to ensure that not using a local datastore is the best decision.

### Option 1: No local datastore
In this option we continue with the platform architecture goals.

#### Pros
+ Single source of truth - all data is in the Publishing API
+ Multiple apps can edit the same content
+ Single implementation of scheduling and publishing logic
+ Single abstraction layer

#### Cons
- Effectively building an Active Resource layer (object-relational mapper for REST)
- Harder to resolve performance problems
- Current workflow is opinionated and may not meet needs of content
- Testing against an API is hard, it requires a lot of stubbing or running a version of the API as part of the test suite

### Option 2: Use a local datastore
#### Pros
+ It’s standard Rails so quick to build and easy to understand
+ Easy to test, testing with a local datastore is very straightforward
+ Easy to iterate workflow, changing the API workflow is much harder
+ Only final state of content can be put into Publishing API - some formats will need interim data which isn’t needed for publishing
+ No new features needed for meta data - notes, and other publisher info

#### Cons
- Syncing between local and Publishing API
- Local data is hard to query by other applications
- Expanded Links
- Combination of local and Publishing API workflows
- Hard to feedback to use on asynchronous API updates
- Content-Schema may not match Rails validations causing unhelpful error messages

## Decision
We will use a local datastore which syncs to the Publishing API.

## Status
Accepted

## Consequences
The problems we found when building and maintaining specialist-publisher have shown that the practicalities of not having a local datastore outweigh the architectural purity of a single datastore.

There will be problems in keeping the local datastore and the publishing API in sync in addition to the user experience problems of updating users on the results of asynchronous updates. However the speed and ease of development improvements should outweigh this.

[Publishing API]: https://docs.publishing.service.gov.uk/apps/publishing-api.html
[Specialist-publisher]: https://docs.publishing.service.gov.uk/apps/specialist-publisher.html
