# Content Publisher

A unified publishing application for content on GOV.UK

## Nomenclature

  * Content - Some text ([and related fields][content-schemas]) a user wants to publish
  * Revision - A version of a piece of content in a particular locale
  * Edition - A revision that is in the Publishing API
  * Document - All revisions of a piece of content in a particular locale

## Technical documentation

This is a Ruby on Rails application.

### Dependencies

- [postgresql][] - provides a backing database
- [redis][] - used as a storage layer for asynchronous job processing
- [yarn][] - package manager for JavaScripts
- [imagemagick][] - image manipulation library

### Running the application

The first time you run this application for development, enable `debug` and `pre_release_features` permissions:

```
bundle exec rake development_permissions
```

To enable them for your GOV.UK account add them to your account in [Signon](https://github.com/alphagov/signon).

### Running the test suite

```
yarn install
bundle exec rake
```

#### Running JavaScript tests only

Running [Jasmine][] tests in local web browser

```
bundle exec rake jasmine
```

Running [Jasmine][] tests in console

```
bundle exec rake jasmine:ci
```

### Debugging the application

This application uses [byebug](https://github.com/deivid-rodriguez/byebug) for
debugging. A breakpoint can be inserted by inserting a line of
`byebug` into the ruby code.

As this application is run via foreman it is not easy to interact with the
debugger via the running processes. Instead the debugger should be accessed
by creating a remote debugging session with byebug and listening. This can be
done by running the following in a separate terminal window:

```
bundle exec byebug -R localhost:3237
```

which will listen for the web application. Substitute port 3237 for 3238 to
listen to the sidekiq processes.

### Further documentation

- [Removing documents](docs/removing-documents.md)
- [Approach to analytics](docs/approach-to-analytics.md)

## Licence

[MIT License](LICENCE)

[content-schemas]: https://github.com/alphagov/govuk-content-schemas
[postgresql]: https://www.postgresql.org/
[redis]: https://redis.io/
[yarn]: https://yarnpkg.com/
[jasmine]: https://github.com/jasmine/jasmine
[imagemagick]: https://www.imagemagick.org/script/index.php
[whitehall-repo]: https://github.com/alphagov/whitehall
[export-filters]: https://github.com/alphagov/whitehall/blob/master/lib/tasks/export.rake#L153
