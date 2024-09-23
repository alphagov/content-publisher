# Content Publisher

A unified publishing application for content on GOV.UK

## Nomenclature

  * Content - Some text ([and related fields][content-schemas]) a user wants to publish
  * Revision - A version of a piece of content in a particular locale
  * Edition - A revision that is in the Publishing API
  * Document - All revisions of a piece of content in a particular locale

## Technical documentation

This is a Ruby on Rails application, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Before running the app

The first time you run this application for development, enable `debug` and `pre_release_features` permissions:

```
bundle exec rake development_permissions
```

To enable them for your GOV.UK account add them to your account in [Signon](https://github.com/alphagov/signon).

### Running the test suite

**Note:** You will need to checkout `govuk-helm-charts` into your `govuk` repository in order to have local tests passing. 

```
bundle exec rake
```

To run JavaScript tests (only):

```
# run JS tests in browser
yarn run jasmine:browser

# run JS tests on command line
yarn run jasmine:ci
```

> [Our test environment is setup to render 'real' error pages, instead of raising an exception](https://github.com/alphagov/content-publisher/commit/184a93d23551161125c1ac6ff3d9287eafabbc3d). This can make it hard to debug a test failure, as the actual error won't appear in the test output. Instead, you can see it in `log/test.log`.

### Further documentation

- [Approach to analytics](docs/approach-to-analytics.md)
- [Editing change note history](docs/edit-change-note-history.md)
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
