# MEGA Content Publisher

Richard's experiment extending content publisher to be less specific to GOV.UK's use case.

### Hacking the thing to run locally

Get postgres running, for example with docker:

```
docker run -d -e POSTGRES_PASSWORD=password -e POSTGRES_USER=postgres -p 5432:5432 postgres
```

Export environment variables to let future commands know which DBs to talk to:

```
export TEST_DATABASE_URL=postgres://postgres:password@localhost:5432
export DATABASE_URL=postgres://postgres:password@localhost:5432
```

Create the databases for development and test:

```
bundle exec rails db:create
bundle exec rails db:schema:load
```

Create permissions for running in Mock SSO mode:

```
bundle exec rake development_permissions
```

Start rails:

```
bundle exec rails s
```

You can then almost publish "statutory guidance" (only you can't really, because you need publishing api to be there).

To work around the absence of publishing api, you can use [stublishing-api](https://github.com/richardTowers/stublishing-api).

This will run on port 9999, so you need to set a variable to override the location in content-publisher:

```
PLEK_SERVICE_PUBLISHING_API_URI=localhost:9999 bundle exec rails s
```

## TODO

* [x] Get a working publishing journey together using [stublishing-api](https://github.com/richardTowers/stublishing-api)
* [x] Update the blog content type so it's got the nice helpful text
* [ ] Add webhook functionality to allow triggering builds of the frontend for newly published blog posts

