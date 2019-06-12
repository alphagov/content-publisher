# 11. Moving business logic out of controllers

Date: 2019-06-03

## Context

Over time the controller classes for Content Publisher have become
[increasingly complex][complex-controllers] as the application grew in size
and functionality. This has led to action methods that are long, difficult to
understand and expensive to test. Looking towards the future it can be
anticipated that there will be more functionality in controllers, such as
access limiting, concurrent editing protection and invalid state handling.
Therefore, there is an expectation that controllers would become an increasing
pain point for the application due to their complexity.

This is a common scenario for a growing Rails application. A customary
approach to address this is to distinguish between business and rendering
logic in an action (where business logic is the action the user requested,
such as changing application state, and rendering logic is the process of
building the response to be returned to the user) and to move business logic
outside of the controller action to another class.

Within the Content Publisher team we have been evaluating
a number of patterns and tools for creating business logic classes. We came to
the following conclusions:

- [Service objects][service-objects]: This is a pattern already used in
  Content Publisher, however it is used to perform distinct application tasks
  rather than being coupled to particular controller actions. We felt the
  services directory had become a mess in Content Publisher, with little
  consistency between service objects.
- [Dry-transaction gem][dry-transaction]: This provides a nice interface for
  managing responses through [ruby blocks][calling-a-dry-transaction]. However
  dry-transaction requires a strict adherence to a provided DSL which can make
  a transaction class very different from a plain old Ruby object.
- [Interactor gem][interactor-gem]: This is a simple, relatively free-form
  pattern (no DSL) that uses a `context` object for basic control flow. It has
  a disadvantage that the input and output are not particularly clear.
- [Trailblazer operation][trailblazer-operation]: This gem provides a DSL for
  creating classes to perform a business operation. It works best within a
  Rails application that has embraced the collection of Trailblazer utilities.
- [Publishing API command pattern][pub-api-command]: This is an effective
  pattern at moving logic out of controllers. However, we felt it had become
  convoluted and inflexible due to domain logic coupling.

## Decision

Content Publisher will make use of the [Interactor gem][interactor-gem] as the
tool to implement classes for performing controller business logic. The logic
within controller actions will be focused on producing a HTTP response.

Interactors for controller actions are intended to be coupled to a
particular action and not be reused outside that context. This is to maximise
clarity (in purpose and naming) and to minimise the logic, options and outcomes
of an interactor.

Interactors should be created for all controller actions that mutate
application state (typically POST/PUT/PATCH/DELETE requests). Only in cases
where an action is very simple should an interactor not be used.

For controller actions that don't mutate application state (such as GET
requests) interactor classes may be created, if beneficial in abstracting
complexity. In most cases these types of requests have low amounts of code
and so use of this pattern would not be advantageous.

Interactors are stored in the `app/interactors` directory, within here
there are directories created for each controller to store the interactors for
each action, in a pattern similar to views. Each interactor class name is
suffixed with "Interactor", to make their purpose clear. As an example,
given a `create` action on a `DocumentsController` there is a corresponding
interactor to create a document, `Documents::CreateInteractor`, which is stored
in `app/interactors/documents`.

The Interactor gem was chosen over writing our own framework for handling
business logic, as per the Publishing API command approach, for the following
reasons:

- a bespoke problem is not being solved, so it shouldn't require a bespoke
  solution;
- authoring a new pattern is something that requires documentation, maintenance
  and iteration;
- It’s harder to [bikeshed][] on decisions made externally.

We felt that compared to other community gems, such as dry-transaction and
Trailblazer, Interactor offered a lower learning curve, greater flexibility
and a lower dependency overhead. We also felt that as the gem is quite simple,
using it would not preclude us from building, or changing to, a different
approach were our needs to change or we found a problem with the gem.

## Status

Accepted

## Consequences

Many of the controller actions in Content Publisher have been refactored to
make use of the Interactor gem. This has resulted in an increase in the
number of classes of the application while the size and complexity of
controller classes have decreased.

Conventions have been established on a consistent approach to writing
interactors. These have focused on:

- [initialising interactors with request parameters and a user][initialize-example];
- [writing interactor `call` methods as a sequence of (no-argument)
  method calls][call-method-example];
- [using delegation to reduce repetitive references to the `context`
  variable][delegation-example];
- [setting variables on context to be used to determine HTTP
  response][response-example],
  rather than using `Context#success?` / `Context#failure?` methods, which
  allows the code to be more explicit about which success/failure scenario
  occurred.

[complex-controllers]: https://github.com/alphagov/content-publisher/blob/1eb067d35d557982f05601cde33c93f9ebea5694/app/controllers/images_controller.rb#L55-L101
[service-objects]: https://medium.com/@scottdomes/service-objects-in-rails-75ca74214b77
[dry-transaction]: https://dry-rb.org/gems/dry-transaction/
[calling-a-dry-transaction]: https://dry-rb.org/gems/dry-transaction/basic-usage/#calling-a-transaction
[trailblazer-operation]: http://trailblazer.to/gems/operation/2.0/
[pub-api-command]: https://github.com/alphagov/publishing-api/tree/29e84d61e323ab1020813ae5e3c797e0c781a4d0/app/commands
[bikeshed]: https://en.wiktionary.org/wiki/bikeshedding
[interactor-gem]: https://github.com/collectiveidea/interactor
[initialize-example]: https://github.com/alphagov/content-publisher/blob/e24ae71cb3a27889c1e09b0ec6135dfd20ffb7a1/app/controllers/documents_controller.rb#L31
[call-method-example]: https://github.com/alphagov/content-publisher/blob/e24ae71cb3a27889c1e09b0ec6135dfd20ffb7a1/app/interactors/documents/destroy_interactor.rb#L12-L16
[delegation-example]: https://github.com/alphagov/content-publisher/blob/e24ae71cb3a27889c1e09b0ec6135dfd20ffb7a1/app/interactors/documents/destroy_interactor.rb#L5-L9
[response-example]: https://github.com/alphagov/content-publisher/blob/e24ae71cb3a27889c1e09b0ec6135dfd20ffb7a1/app/controllers/documents_controller.rb#L32-L37
