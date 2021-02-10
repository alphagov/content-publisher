# Content Publisher

A unified publishing application for content on GOV.UK

## Nomenclature

  * Content - Some text ([and related fields][content-schemas]) a user wants to publish
  * Revision - A version of a piece of content in a particular locale
  * Edition - A revision that is in the Publishing API
  * Document - All revisions of a piece of content in a particular locale

## Technical documentation

This is a Ruby on Rails application. You can use the GOV.UK Docker environment to run the application and its tests with all the necessary dependencies; **see the [README](https://github.com/alphagov/govuk-docker#usage) for more details**.

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
# ruby tests
bundle exec rspec

# JS tests (in console, or in browser)
bundle exec rake jasmine:ci
bundle exec rake jasmine
```

> [Our test environment is setup to render 'real' error pages, instead of raising an exception](https://github.com/alphagov/content-publisher/commit/184a93d23551161125c1ac6ff3d9287eafabbc3d). This can make it hard to debug a test failure, as the actual error won't appear in the test output. Instead, you can see it in `log/test.log`.

### Further documentation

- [Approach to analytics](docs/approach-to-analytics.md)
- [Editing change note history](docs/editing-change-note-history.md)
- [History mode](docs/history-mode.md)
- [Importing documents from Whitehall](docs/import-from-whitehall.md)
- [Removing documents](docs/removing-documents.md)
- [Scheduled publishing](docs/scheduled-publishing.md)
- [Testing strategy](docs/testing-strategy.md)
- [User permissions](docs/user-permissions.md)

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
