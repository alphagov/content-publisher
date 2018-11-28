# 5. Avoiding initialisation flickering in HTML

Date: 2018-11-27

## Context

A common problem with website initialisation is that there can be elements of the
page that you want to be hidden until a user performs an action via JavaScript.
However if a user does not have JavaScript you want the item to always be
visible.

When the page loads this can cause a distracting flash as it quickly hides or
replaces content and can appear like the page has a loading issue to a user.

On content publisher there have been a number of issues flagged in testing
relating to these flashes, with different ad-hoc fixes applied. This ADR is
intended to define a route forward for them to be handled consistently.

There were 3 options considered:

### 1. Do nothing

This option involved considering the flash to be a natural consequence of
progressive enhancement.

### 2. Hide content before JavaScript initialisation with a `js-enabled` class

We have a class that is inserted in the body element of a HTML document while
the page is loaded that sets whether the user has JavaScript enabled.

This class can therefore be used to hide elements on the page in advance of
JavaScript initialisation to avoid the flicker.

The downside that this approach has is that there is not a fallback for if
JavaScript is enabled on a device but fails for some reason.

### 3. Implement an initial hiding approach resilient to JavaScript failing

The final approach considered was the introduction of a second class in addition
to `js-enabled` on the body element that would be `js-failed`. This would
involve enhancing the initial adding of a class from:

```
document.body.className = ((document.body.className) ? document.body.className + ' js-enabled' : 'js-enabled');
```

to something like:

```
document.body.className = ((document.body.className) ? document.body.className + ' js-enabled' : 'js-enabled');
setTimeout(function() {
  if (!window.jsInitialised) {
    document.body.className += ' js-failed';
  }
}, 2000);
```

Which would allow a 2 second grace period before changing the body class so
fallback content is displayed.

CSS rules would need to be updated to show content when either `js-enabled` or
`js-failed` was present


## Decision

A decision was made that in interim we should take option 2 and just use the
`js-enabled` class. This was deemed the most pragmatic approach as option 1 was
causing problems for our testers and option 3 was considered something unusual
that wanted to be investigated further.

## Status

Accepted

## Consequences

Users who have JavaScript enabled in their browser but have had JavaScript fail
to initialise (as outlined in the [Service Manual][service-manual-js]) may have
a degraded or broken experience.

Alex and Dilwoar intend to discuss this further at the frontend meeting so we
can arrive at an eventual solution that can be consistently applied to GOV.UK.

[service-manual-js]: https://www.gov.uk/service-manual/technology/using-progressive-enhancement#dont-assume-users-turn-off-javascript
