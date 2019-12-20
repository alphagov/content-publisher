# 15. Bulk data loading

Date: 2019-12-19

## Context

Content Publisher regularly has to present users with long lists of data that
is loaded from the Publishing API, examples of these are organisations,
contacts and the topic taxonomy. Content Publisher typically needs to
download all the records of a particular datatype, which can involve
multiple HTTP requests. When this is done during a web request the application
is at an increased risk of returning a slow response or even timing out.
The risks of this have been partially mitigated by caching.

These situations where Content Publisher needs all the data records for a
particular dataset are colloquially referred to as bulk data. This is
distinguished from other API look ups where we may need to access a
single resource (such as looking up the topic tags) that have less risks of
performance penalties.

This particular problem has been faced and solved for GOV.UK before. Whitehall
takes an [approach](https://github.com/alphagov/whitehall/pull/3298) for the
topic taxonomy where the data is loaded at runtime from
[Redis](https://redis.io/). A periodic background job then refreshes the
data in Redis. This avoids the need to look up the data during a web request.

## Decision

In Content Publisher we have chosen to implement a similar pattern to Whitehall.
Data is read from Redis at runtime and a background process runs a periodic
job to re-populate the Redis data.

This approach makes use of the [Rails Redis cache store][redis-cache-store]
which is wrapped within an object, [BulkData::Cache][bulk-data-cache], for
writing and accessing data. We have introduced a concept of
[repository][government-repository] classes that can be used to work with the
loading and modelling of data that is stored in the cache.

On application boot and on a recurring 15 minute interval a
[background job][populate-bulk-data-job] will run to try to re-populate the data.
In the event of an error occurring this job will log this issue and retry. If
retries are exhausted a decision will be made whether to
[send the error to Sentry or not][error-handling] based on whether the error
is likely to be a problem we will investigate.

The data within the bulk data cache is stored with an expiry of 24 hours, which
is a lot longer than the interval we use to re-populate the cache. The reason
for such a long time is to provide as a safety net for problems to occur and
not to present any sign of issues to users until this period has expired. If a
frontend request is made for a resource that requires bulk data, and the
cache entry for that is empty, a [503 response][unavailable-response] is
returned to the user and the job to re-populate the cache is enqueued.

If we hit a scenario where there are errors with the jobs there is a chance
that we will slowly build up a large queue of this same job multiple times. To
prevent this situation causing any significant problems (such as flooding the
Publishing API with requests) the job will only populate data where [the
data is older than 5 minutes][older-than-check].

## Status

Accepted

## Consequences

For Content Publisher to operate normally the bulk data cache will be expected
to be populated. In the development environment this has the consequence that
developers should always run the application with the background worker
process. In a test environment the bulk data cache will need to be populated
before and cleared after any test run that makes use of it,
[helpers][bulk-data-helpers] have been provided for this task.

Data that is currently loaded at runtime (such as organisations, contacts and
topics) should be migrated to use the bulk data approach to reduce the risk of
timeouts and slow responses for users.

The switching of loading data from a runtime task to a background task allows
Content Publisher to load richer data from the Publishing API. This is
intended to be used to enable eventual features such as: acronyms of an
organisation or time a minister was in appointment.

The use of a scheduled task increases the risk of sending Sentry unactionable
error alerts. In the staging and integration environments there is a high
chance of errors occurring during the data sync process. We intend to
review any errors that come in as part of this and adjust reporting thresholds
to try exclude them.

[redis-cache-store]: https://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-rediscachestore
[bulk-data-cache]: https://github.com/alphagov/content-publisher/blob/265226bc0c613d2294b4cb0d33d2f26cfcf54811/lib/bulk_data/cache.rb
[government-repository]: https://github.com/alphagov/content-publisher/blob/265226bc0c613d2294b4cb0d33d2f26cfcf54811/lib/bulk_data/government_repository.rb
[populate-bulk-data-job]: https://github.com/alphagov/content-publisher/blob/265226bc0c613d2294b4cb0d33d2f26cfcf54811/app/jobs/populate_bulk_data_job.rb
[error-handling]: https://github.com/alphagov/content-publisher/blob/265226bc0c613d2294b4cb0d33d2f26cfcf54811/app/jobs/populate_bulk_data_job.rb#L4-L6
[unavailable-response]: https://github.com/alphagov/content-publisher/blob/265226bc0c613d2294b4cb0d33d2f26cfcf54811/app/controllers/application_controller.rb#L31-L37
[older-than-check]: https://github.com/alphagov/content-publisher/blob/265226bc0c613d2294b4cb0d33d2f26cfcf54811/app/jobs/populate_bulk_data_job.rb#L10
[bulk-data-helpers]: https://github.com/alphagov/content-publisher/blob/e8f2f7713f16e1c2bbbdd0c0c3181e0b317ae80e/spec/support/bulk_data_helper.rb
