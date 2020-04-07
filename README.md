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

### Further documentation

- [Approach to analytics](docs/approach-to-analytics.md)
- [Editing change note history](docs/editing-change-note-history.md)
- [History mode](docs/history-mode.md)
- [Importing documents from Whitehall](docs/import-from-whitehall.md)
- [Removing documents](docs/removing-documents.md)
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
