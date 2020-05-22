# Scheduled publishing

Editions in Content Publisher can be scheduled to publish at a designated
time. This is done by scheduling an [ActiveJob][] which queues a job for
the specified time in Redis. A risk with the scheduling publishing system
is that if the data in Redis is lost the job won't run and the publishing
won't occur.

## Repopulate all scheduling jobs

We have a rake task that will re-populate the scheduling for all editions that
are scheduled to be published (including those where the time has already
passed). This can be used if the data of scheduled jobs in Redis is lost or
is invalid.

```
rake scheduling:repopulate
```

## Fixing a single failed scheduled publishing

If a single edition fails to be published then this edition can be resolved
through the publisher interface. This is done by finding the edition, stopping
the scheduling publishing, clearing the proposed publish time and then
publishing it.

[ActiveJob]: https://guides.rubyonrails.org/v6.0/active_job_basics.html
