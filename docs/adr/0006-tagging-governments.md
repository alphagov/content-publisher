# 6. Tagging Content to Governments

Date: 2018-12-12
Superseded: 2019-12-19 by [ADR 14](0014-political-and-government-tagging.md)

## Context

Content published by Whitehall can be marked as 'political' and associated with a government (based on it's publication date). This is used to help indicate the content may no longer accurate as governments change over time.

Marking content as a political is a semi-automated process, which has the effect of adding two extra attributes to the payload we send to the Publishing API. Both attributes are required for them to be used by the frontends.

```
{
  ...,
  "details": {
    "government": {
      "title": "My Current Government",
      "slug": "/my-current-government",
      "current": true
    },
    "political": true
  }
}
```

There were 3 options considered:

### 1. Do not implement

This would require changing the [content schema for news articles][news-article-schema] so that the `government` and `political` attributes are not required. We've checked to see the frontends do not require these attributes to be set.

### 2. Implement like Whitehall

This would require us to replicate the [semi-automatic logic][whitehall-political-identifier] in Whitehall to identify political content, as well as extend our UI to allow users to mark content as political and change the publication date.

### 3. Implement from scratch

This would involve designing our own UI to associate content with a government and/or mark it as political. After some discussion with the people who worked on adding this feature to GOV.UK, we believe there is scope for improvement.

## Decision

We decided to go with option (1) and defer implementing support for political content. The implementation in Whitehall has several disadvantages, which we think merit further research with users:

   * The `political` and `government` attributes are part of the content of a document, which means they contain redundant data.
   * Storing the attributes in the content also means all documents must be republished when the current government changes.
   * The effect of marking content as political is unclear, and the link between publication date and government is not visible.
   * It's unclear if associating content with a government and marking it as political are separate concerns or the same thing.

Since manual intervention is required whether or not we implement the current approach, we think it's reasonable to defer supporting it until we have more knowledge to address the issues it presents.

## Status

Superseded

## Consequences

[news-article-schema]: https://github.com/alphagov/govuk-content-schemas/blob/master/dist/formats/news_article/publisher_v2/schema.json
[whitehall-political-identifier]: https://github.com/alphagov/whitehall/blob/7b5c5a086b89cb62ffba62b152a0a8dcfc10c8e6/lib/political_content_identifier.rb
