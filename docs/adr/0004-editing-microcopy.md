# 4. Editing Microcopy

Date: 2018-09-11
Revised: 2020-01-21

## Context

Every feature we add to the app comes with its own static text, which is either embedded in the code (Ruby or JavaScript) or in the HTML. Static text can be anything from the page title, to the text of a button, to an entire page of guidance.

Writing text 'inline' makes it hard for us to audit all of strings in our application, some of which can only be seen under special conditions e.g. error messages. It also makes it hard to change strings consistently across the application - a task which has to be done by a developer. Finally, using inline strings in code distracts from the logical flow of that code.

[Rails Internationalization](https://guides.rubyonrails.org/i18n.html) (also referred to as 'translations') are a way to extract all of the strings in the application to a central location in `config/locales/en`. The strings can be organized in a hierarchy over one or more files, as below, where we can refer to the reviewed title by writing `I18n.t("publish.published.reviewed.title")`.

```
# publish_document/published.yml
en:
  publish_document:
    published:
      reviewed:
        title: Content has been published
        body: |
          ‘%{title}’ has been published on GOV.UK.

          It may take 5 minutes to appear live.

```

Rails translations have a few special behaviours, such as pluralization, raw HTML, and variables. The `%{title}` string in the above is an example of a variable, which a developer will set to the title of the document being published.

## Testing

We considered a few approaches for how to extract the strings in our tests. As we started to extract more strings, we had to consider the affect on the readability of the tests and how we could maintain readability/consistency/flexibility.

   * Extract all of the strings in the application and tests. This is consistent and give maximum flexibility for people making changes, but would make the tests hard to read due to the volume of calls to the translation/model APIs.
   * Extract all of the strings in the application but leave some in the tests. This would be inconsistent for developers to implement and for anyone trying to make a change, as it it's unclear if the tests would need to be fixed. It has the upside that we could select which translations to use in the tests to maintain readability.
   * Extract a subset of strings in the application and extract the same subset in the tests. This is consistent and flexible, provided the subset is clear and covers all/most of the strings that people want to change.

After trying the first option, we found that extracting links and button labels had the greatest impact on readability; we also think these kinds of strings are unlikely to change. As the original intention behind this work was to enable non-developers to seamlessly edit content, we adopted the third option, which appears to be working well for people making changes, but has caused some confusion among the developers as the subset of strings to extract wasn't specified as it is below.

## Decision

Although we could use translations to extract all of the strings in the application, in some cases we felt this wasn't necessary, or that a different method should be used. The following is a summary of the rules we currently use.

   * **Link and button labels** are not extracted. We think link and button labels are unlikely to change, and extracting them made the application tests harder to read by obfuscating some of the crucial steps in the test with translation keys.
   * **Publishing component strings** are not extracted. This ensures we are able to migrate these components to the [govuk_publishing_components](https://github.com/alphagov/govuk_publishing_components) repo, which wouldn't be able to access our local translations.
   * **Big guidance** is extracted into it's own Markdown files and stored alongside the corresponding HTML page that shows it. For example, the guidance for creating a new document is stored in `app/views/new_document/guidance.md`.
   * **Domain data** that's static is stored in a number of custom YAML files. This application has two static models (for document types and their selection) that encapsulate domain concepts where the data is part of the application. We have split up domain data based on whether it's used in a backend setting or as a string for use in the frontend. The latter are extracted at the top-level of the translation hierarchy.
   * **Global strings** (states and validation messages) are extracted using translations. As these strings aren't page-specific, we put them at the top-level of the translation hierarchy (in `states.yml` and `validations.yml`).
   * **All other strings** are extracted using translations, in a hierarchy that follows the structure of the `app/views` directory. For example, the above example relates to `app/views/publish_document/published.html.erb`.
   * **Small amounts of govspeak and HTML** are extracted using translations as for other strings, with '\_html' or '\_govspeak' appended to the final component of the key to indicate they support rich text.

Every instance of a string in the tests has been replaced according to the above rules, such that the tests continue to pass when an extracted string is changed. **Link and button labels** are not replaced, as they are not extracted in the code.

We also configured Rails to raise an exception when we hit a page where a translation is missing, as we don't test all of the translations; this is done by setting `config.action_view.raise_on_missing_translations = true` in `application.rb`.

## Status

Accepted

The approach taken so far is primarily driven by the needs of developers, rather than the needs of the other roles in the team. We should avoid committing to this approach until other people in the team have made more use of it. For example, it may be easier to have fewer files (perhaps per collection of views, to keep things algorithmic), with more content in each file.

## Consequences

Using translations for the most of the strings has allowed members of the team who aren't developers to make changes without a developer or a development environment. Instead, we trained them to use the Github commit and PR interface.

Some people found it hard to find extracted strings, due to them being in multiple, technology-specific locations. It's still unclear how we should structure the extracted strings in a way that makes it easy to find a given string. One way to ignore this problem is to use search (e.g. Github search) to locate the file where the string is stored; this doesn't always work because some strings are only shown under certain conditions (e.g. errors) and therefore may not be widely known.
