# XX. Moving business logic out of controllers

Date: 2019-06-03

## Context

Over time the controller classes for Content Publisher have become
[increasingly complex][complex-controllers] as the application grew in size
and functionality. This has led to action methods that are long, difficult to
understand and expensive to test. Looking towards the future it can be
anticipated that there will be more functionality in controllers, such as
access limiting, concurrent editing protection and invalid state handling.
Therefore there is an expectation that controllers would become an increasing
pain point for the application due to their complexity.

This is a common scenario for a growing Rails application. A customary
approach to address it is to distinguish between business and rendering
logic in an action - where business logic is the action the user requested,
such as changing application state, and rendering logic is the process of
building the response to be returned to the user - and move the business logic
to another class.

Within the Content Publisher team we have been evaluating
a number of approaches to perform our business logic operations, such
as [service objects][],
[the dry-transaction gem][dry-transaction],
[the interactor gem][interactor-gem],
[trailblazer operations][trailblazer-operation] and
the [Publishing API command pattern][pub-api-command]. We came to the
following conclusions:

- Service objects: This is a pattern already used in Content Publisher,
  however it is used to perform distinct supporting tasks rather than being
  coupled to particular controller actions. We felt the services directory had
  become a mess in Content Publisher, with little consistency between service
  objects.
- Dry-transaction gem: This provides a nice interface for managing response
  through [ruby blocks][calling-a-dry-transaction]. However dry-transaction
  requires a strict adherence to a provided DSL which can make a transaction
  class very different from a plain old Ruby object.
- Interactor gem: This is a simple, flexible pattern which relies on
  building up an enhanced open struct based response. It had disadvantages
  that it wasn't particularly clear what input and output was expected.
- Trailblazer operation: This gem provides a DSL for creating classes to
  perform a business operation. It works best within a Rails application
  that has embraced the collection of Trailblazer utilities.
- Publishing API command pattern: This is an effective pattern at moving logic
  out of controllers, it however has produced usage problems where the base
  class is coupled to particular domain logic.

## Decision

Controller actions can use a dedicated class to perform the business logic of
a request. Logic in an action is to be focused on producing the appropriate
HTTP response. To meet this requirement it is expected that classes shall
exist for actions that mutate application state (typically POST/PUT/DELETE
requests) and may exist for actions which don’t mutate state (typically GET)
depending on the request complexity.

Content Publisher makes use of the [Interactor gem][interactor-gem] as the
means to implement these classes. It was chosen over other community
approaches due to it’s simplicity and flexibility. It was decided to use
a community provided framework rather that writing our own, this is
because:

- a bespoke problem is not being solved, so it shouldn't require a bespoke
  solution;
- authoring a new pattern is something that requires negotiation,
  documentation, maintenance and iteration;
- It’s harder to [bikeshed][] on decisions made externally.

The Interactor gem is relativity simple in comparison to similar gems. This
offers the advantage that, were we to discover problems with the gem or a
change in our needs, it would be realistic for us to adapt this to a self
built or different community approach.

Interactor classes are created with a coupling to a particular controller
action. Interactors are stored in an app/interactors directory. Within here
there are directories created for each controller to store the interactors for
each action, in a pattern similar to views. Each interactor class name is
suffixed with "Interactor", to make their purpose clear. As an example,
given a create action on a DocumentsController there is a corresponding
interactor to create a document, Document::CreateInteractor, which is stored
in app/interactors/document.

## Status

Accepted

## Consequences

Many of the controller actions in Content Publisher have been refactored to
make use of the interactor pattern. This has resulted in an increase in the
number of classes of the application while the size and complexity of
controller classes have decreased.

Conventions have been established on a consistent approach to using the
Interactor gem. These have focused on:

- [initialising controllers with request parameters and a user][initialize-example];
- [authoring an interactor's `call` method as a procedure of descriptive
  methods][call-method-example];
- [using delegation to reduce repetitive references to the `context`
  variable][delegation-example];
- [setting variables on context to be used to determine HTTP
  response][response-example],
  rather than using context.success / context.failure methods, this allows the
  code to be more explicit about which success/failure scenario.

Service classes that have a singular purpose could be refactored to use the
interactor pattern. Before this can be done, we will need to decide on a
directory convention for where they should be stored.

[complex-controllers]: https://github.com/alphagov/content-publisher/blob/1eb067d35d557982f05601cde33c93f9ebea5694/app/controllers/images_controller.rb#L55-L101
[service objects]: https://medium.com/@scottdomes/service-objects-in-rails-75ca74214b77
[dry-transaction]: https://dry-rb.org/gems/dry-transaction/
[calling-a-dry-transaction]: https://dry-rb.org/gems/dry-transaction/basic-usage/#calling-a-transaction
[trailblazer-operation]: http://trailblazer.to/gems/operation/2.0/
[bikeshed]: https://en.wiktionary.org/wiki/bikeshedding
[interactor-gem]: https://github.com/collectiveidea/interactor
[initialize-example]: https://github.com/alphagov/content-publisher/blob/e24ae71cb3a27889c1e09b0ec6135dfd20ffb7a1/app/controllers/documents_controller.rb#L31
[call-method-example]: https://github.com/alphagov/content-publisher/blob/e24ae71cb3a27889c1e09b0ec6135dfd20ffb7a1/app/interactors/documents/destroy_interactor.rb#L12-L16
[delegation-example]: https://github.com/alphagov/content-publisher/blob/e24ae71cb3a27889c1e09b0ec6135dfd20ffb7a1/app/interactors/documents/destroy_interactor.rb#L5-L9
[response-example]: https://github.com/alphagov/content-publisher/blob/e24ae71cb3a27889c1e09b0ec6135dfd20ffb7a1/app/controllers/documents_controller.rb#L32-L37
