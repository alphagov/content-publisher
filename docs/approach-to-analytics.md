# Approach to Analytics

Content Publisher uses [Google Analytics](https://analytics.google.com/analytics/web/#/report-home/a124922226w186404040p183397753) (GA) to store events that describe a user action, such as when a user clicks the "[Create new document](https://github.com/alphagov/content-publisher/blob/4b088834621787009528afecb4c3fe876b9cf577/app/views/documents/index.html.erb#L4)" button. Rather than dispatching events to GA directly, we use [Google Tag Manager](https://tagmanager.google.com/#/container/accounts/3880990677/containers/9704122) (GTM) to reduce the need for custom analytics code in the app. In order to keep our analytics robust, we use special 'data-gtm' attributes to consistently identify elements on a page, as other attributes, like CSS classes, will change over time.

**Note:** data submitted by the user should not be tracked. Such data is already stored in the relational database for the app. Developers can provide support on analytics work involving this kind of data.

## Tracking at a High Level

We track most events using a set of `data-gtm` attributes:

   - `data-gtm` uniquely describes the intent of the element (*required*)
   - `data-gtm-value` indicates the value in a choice
   - `data-gtm-click-tracking=true` is used to track custom elements
   - `data-gtm-visibility-tracking=true` tracks when an element appears

The `data-gtm` attribute is the most important to get right. It uniquely describes what we believe the user is doing when they interact with an element (e.g. links, buttons) or a group of elements (e.g. radio buttons).

   - `new-document` - intent is to create a new document (via a button)
   - `create-new-edition` - intent is to create a new edition (via a form)
   - `choose-supertype` - intent is to choose a type (via radio buttons)
   - `footer-raise-support-request` - intent is to ask for support (via a link)

In the last example, we want to make a distinction between two identical links on the same page: one in the header and one in the footer. GTM is then setup to use these standard attributes in the events it sends to GA:

   - **Category** = `data-gtm`
   - **Action** (*set in GTM*) = Click, Visible, Check, Uncheck
   - **Label** = `data-gtm-value`

We also send [additional fields](https://github.com/alphagov/content-publisher/blob/4b088834621787009528afecb4c3fe876b9cf577/app/views/layouts/application.html.erb#L9) to GA that describe the page itself.

   - **User Organisation** e.g. `government-digital-service`
   - **User ID** e.g. `c78492f0-0356-0136-a017-02ada856ca8e`
     - This is also used to [enable a bunch of GA User-ID features](https://support.google.com/analytics/answer/3123662?hl=en)
   - **Page Name** e.g. `documents-show`
     - This is also used to [automatically specify content groupings](https://support.google.com/analytics/answer/2853423?hl=en)


## Basic Tracking by Element

Currently it's not clear what data we need to collect. Until the app reaches maturity, **we've decided to track all user actions**. The following is a list of what this means in terms of HTML Elements.

### Links

```
<a ... data-gtm="new-document" ...>Create new document</a>
```


### Forms

```
<form ... data-gtm="create-new-edition" ...>
  <button ...>Create new edition</button>
</form>
```

Note we track the submission of the form and not the 'submit' button. There are multiple ways to submit a form and tracking the 'submit' button itself (a) won't work and (b) won't capture other ways of submitting the form.

### Buttons

```
<button ... data-gtm="copy-url-for-2i-approval" ...>Copy link</button>
```

### Radios

```
<input type="radio" ... data-gtm="choose-supertype" data-gtm-value="News" ...>
```

Note we track the click/selection of the radio buttons and not the value submitted with the form; as mentioned above, we do not track form submission data. All radios in a radio button group should use the same value for `data-gtm`.

### Checkboxes

This looks the same as they way we track radio buttons and is based on clicks.

```
<input type="checkbox" ... data-gtm="is-lead-image" data-gtm-value="Select as lead image">
```

Unlike radios, we do a bit of post-processing in GTM to detect when the box is checked or unchecked.

## Other Tracking Techniques

### Visibility

Sometimes we need to track when something is shown to a user on a page (e.g. an error message).

```
<a ... data-gtm="requirements-issue"
       data-gtm-value="Enter a change note"
       data-gtm-visibility-tracking="true" ...>Enter a change note</a>
```

This example also shows how we can combine different kinds of tracking (click, visible) for an element.

### Custom Elements

We need to manually enable tracking for clicks on elements that aren't buttons, links, etc.

```
<md-header-2 ... data-gtm="markdown-toolbar-h2" data-gtm-click-tracking="true" ...>
  ...
</md-header-2>
```

### UTM / Inbound Links

GA has fields to track the origin of inbound links to a site. Unfortunately, this mechanism was only designed with paid advertising as the use case, so the fields don't make much sense for things like links in emails. Our take on it:

   - **Source** is the place the user found a link; usually this is on another site like 'Google', but in our case it makes more sense to refer to the feature they were using, such as '2i-link' or 'publish-email'
   - **Medium** is the context in which a user uses a link; usually this is something like 'email', or 'cpc' for paid adverts; in our case we use 'email' and 'copy-paste' (for explicit URLs we give out in the app)
   - **Campaign** is just a way of grouping the other attributes, in case other people pollute our analytics with their own source/medium for some reason; we always set this to `govuk-publishing`

The following example is for a link shown in the app itself.

```
http://content-publisher.dev.gov.uk/documents/900969d4-a919-4d3d-bd16-eee8b6c5cd94:en?utm_campaign=govuk-publishing&utm_medium=copy-paste&utm_source=2i-link
```

This shows the different query params we set in order to populate the above fields in GA. Note that `utm_source` and `utm_medium` are required params: if one is not set then the other fields will not be set either.

   - **Source** = `utm_source` e.g. `2i-link`
   - **Medium** = `utm_medium` e.g. `copy-paste`
   - **Campaign** = `utm_campaign` i.e. `govuk-publishing`

### Copy / Paste

Copy/paste events are not supported by GTM directly, so we have some [in-app code](https://github.com/alphagov/content-publisher/blob/4b088834621787009528afecb4c3fe876b9cf577/app/assets/javascripts/modules/gtm-copy-paste-listener.js) to listen for them and manually push them into GTM, which is setup to receive the custom events and send them to GA like this:

   - **Category** = `data-gtm`
   - **Action** = Copy, Paste

The following example shows how to enable copy/paste tracking for an input element. We still make use of our standard `data-gtm` attribute to describe the intent of the element.

```
<input ... data-gtm="published-content-link-input" data-gtm-copy-paste-tracking="true" ...>
```

### Topics

Analytics for topics is hard because the elements the user interacts with - to search for topics and to remove selected topics - are generated dynamically, so we can't annotate them with `data-gtm` attributes like we do normally.

In order to track these actions, we have some [in-app code](https://github.com/alphagov/content-publisher/blob/222570884b6c20f3e5dab85a30a1ed5c837d492b/app/assets/javascripts/modules/gtm-topics-listener.js#L3) to listen for special, internal events that we generate when a user [selects a topic from search results](https://github.com/alphagov/content-publisher/pull/1211) or [removes a selected topic](https://github.com/alphagov/miller-columns-element/pull/15). We then take the same approach for copy/paste and manually push the events into GTM, which is setup to receive the events and send them to GA like this:

   - **Category** = select-topic-from-search-results, remove-topic
   - **Action** = Click
   - **Label** = e.g. *Level 1 Topic > Level 2 Topic > Level 3 Topic*
