# Testing Strategy

We aim for Content Publisher to have a test suite that provides developers
with value. We want the application to be fast to test; for the tests to catch
breaking behavioural changes; and for it to be easy for developers to know
where to add tests. The purpose of this document is
to provide a summary of the testing approaches used so that new and old
developers to Content Publisher have a shared understanding.

The principles we most value in testing are:

- consistency across tests over developer preference - all tests should
  feel like they could have been written by the same person;
- readable tests that are easy to follow - aim for expectations to be clear,
  setup code to be close to associated assertions and avoid being overzealous
  in removing repetition;
- avoid testing configuration - tests should be focused on testing logic we've
  introduced, rather than whether or not our code was typed correctly;
- pragmatism in what we test - if all code paths of a class/module are
  exhausted by other tests then we may not need to explicitly test something
  further.

This testing strategy was inspired by:
[Whitehall Testing Guidelines][whitehall-tests],
[Email Alert API Testing][email-alert-api-tests], and
[Thoughtbots' How We Test Rails Applications][thoughtbot-rails-tests].

## Tests directory structure

Tests for Content Publisher are stored in the [spec](../spec) directory with
the Ruby tests written using [RSpec](https://rspec.info/) and JavaScript tests
written using [Jasmine](https://jasmine.github.io/).

As per Rails convention, most of the directories within the spec directory
contain Ruby [unit tests](#unit-tests) with the directories matching
those within the app directory. Code that is stored in the lib directory has
corresponding tests in the spec/lib directory.

Directories within spec that don't contain Ruby unit tests are as follows:

- factories - contains [FactoryBot factories][factory-bot], which are a fixture
  alternative;
- fixtures - contains supporting files for tests (for example image files) which
  aren't easily produced by factories;
- features - contains [feature tests](#feature-tests), which test that a user
  can accomplish a task by interacting with the applications web interface;
- javascripts - contains [unit tests](#unit-tests) for JavaScript files
  and configuration and helper files for Jasmine;
- requests - contains [request tests](#request-tests), which test the HTTP API
  of the application;
- support - contains helper files for shared test methods and logic;
- views - contains [view tests](#view-tests), which are used to test that
  [Rails views][rails-views] output expected HTML in a given scenario.

## Unit tests

The purpose of these tests is to test individual units of the system in
isolation. They are intended to provide exhaustive tests of the code paths
through a particular class or module through its public interface. As per
the [test pyramid](https://martinfowler.com/bliki/TestPyramid.html) approach
to software testing, these should provide the greatest volume of tests for
the application.

Characteristics of unit tests:

- they should be concerned with the logic within the class/module being tested,
  and not test logic defined elsewhere;
- they may mock dependent objects and/or assert that particular external
  methods are called;
- they should test all code paths through a class/module;
- they should test that side effects intended by the code occur, for example
  writing to the database or making API calls.

## Feature tests

The purpose of these tests is to assert that a user can accomplish a task. A
task being one of the distinguishing features of the application, such as
schedule a document for publishing or add topics to a document. The means
this is asserted is through interacting with the application's web interface
via the same means (for example clicking links or submitting forms) that
we'd anticipate a user to do so.

This type of test provides a high level functional test and helps to
validate that a user can use the application to complete the tasks they use
it for. This makes these tests some of the most valuable of the application,
however they are slower than other tests to run and can be difficult to debug.
Therefore they are not intended to exhaustively test all the scenarios that
can occur as part of a distinct feature.

Characteristics of feature tests:

- they should navigate the application through the web interface with a minimal
  amount of set-up and direct visiting of links, for example most navigation
  should be achieved by user clicking;
- they shouldn't test dead-ends in a user flow (such as validation or
  permission issues), these are simpler tested in
  [request tests](#request-tests);
- they shouldn't test the effects a test has on the database, only user visible
  signs of success should be asserted on;
- they shouldn't mock application code;
- they may mock and/or assert that particular API calls are made to external
  services;
- they should be written in the [readable feature test
  style][readable-feature-tests] popularised by Futurelearn.

## Request tests

The purpose of these tests is to test the HTTP API for the application from
a machine perspective. They are used to determine that for a given input and
application state a particular response is returned. These differ from feature
tests in that they test a single endpoint at a time and can exhaust the logical
outcomes of that endpoint where some situations may be difficult for
a user to fall into.

Characteristics of request tests:

- they should test the variety of responses an endpoint returns, checking
  aspects of the response such as status code and any flash messages;
- they shouldn't test responses where there isn't specific logic written for
  the scenario, for example when relying on Rails' implicit rescue responses
  for `ActiveRecord::RecordNotFound` or `ActionController::ParameterMissing`;
- they should assert against the HTTP responses involved in the request, and
  not side-effects such as database changes, these are better suited to [unit
  testing](#unit-tests) an [interactor][interactors];
- they should focus on the effects of a single endpoint with a single HTTP
  method at a time, for example `POST /documents`, for multiple endpoints
  consider whether you are testing a [feature](#feature-tests);
- they may test a subsequent redirect request when the effects of the endpoint
  under test alter the redirect, for example inserting a flash message;
- they act as integration tests and thus shouldn't mock application code;
- they can mock external API calls, but these should not be asserted against -
  this is better suited to [unit tests](#unit-tests);
- they shouldn't be used to test logic in a rendered view, this is better
  suited by [view tests](#view-tests);
- they may not be necessary for places where a response doesn't have logic
  and already has coverage provided by a feature test.

## View tests

The purpose of view tests is to assert that the expected HTML is rendered in a
particular scenario. Typically it isn't necessary to have view tests as the
use of complex logic is discouraged in views and often aspects of views are
implicitly tested in feature or request tests. However when it is suited for
us to test particular HTML output they are the most appropriate choice.

Characteristics of view tests:

- they should make assertions based on logic in the view, for example they
  should test that certain HTML appears as a result of conditionals and input
  rather than being used to determine exact responses of HTML;
- inputs into tests and dependent objects can be mocks of the expected object;
- they should follow the conventions of
[RSpec Rails view tests][rspec-rails-views].

[whitehall-tests]: https://github.com/alphagov/whitehall/blob/099f53e35cdd0ea63a2349be3766c98e65521ce3/docs/testing.md
[email-alert-api-tests]: https://github.com/alphagov/email-alert-api/pull/300/commits/bf087c28442629bf672be67441fd224f6d746fa5
[thoughtbot-rails-tests]: https://thoughtbot.com/blog/how-we-test-rails-applications
[factory-bot]: https://github.com/thoughtbot/factory_bot
[rails-views]: https://guides.rubyonrails.org/testing.html#testing-views
[readable-feature-tests]: https://about.futurelearn.com/blog/how-we-write-readable-feature-tests-with-rspec
[interactors]: adr/0011-moving-business-logic-out-of-controllers.md
[rspec-rails-views]: https://relishapp.com/rspec/rspec-rails/v/3-9/docs/view-specs/view-spec
