# 12. Rendering File Attachments outside of Govspeak

Date: 2019-06-24

## Context

Content Publisher provides functionality that allows a publisher to embed a
file attachment into the content of their document. This is then
[presented on GOV.UK][attachment-example] as a block of content with metadata
about the file and a link to access it. This presentation process is described
as the rendering of a file attachment.

File attachments are rendered on GOV.UK pages through the use of
[Govspeak][govspeak], which is a GOV.UK specific markdown dialect. Govspeak
has the means to convert a markdown syntax into the HTML needed to display
the attachment on GOV.UK.

When introducing the file attachment feature to Content Publisher we wanted to
provide a user with a preview of how their attachment would look outside of
the context of their document. This would be the same in appearance as a
Govspeak rendered file attachment but ideally with small modifications (such
as opening links in a new window and tracking user interactions).

We considered 3 different approaches to how we could achieve that functionality:

### 1. Render file attachment as Govspeak outside of a document

This would involve creating small blocks of Govspeak for each place where we
wish to show a file attachment outside of the context of a document.

Pros:

- allows re-use of existing attachment rendering logic;
- attachment presentation logic is not duplicated.

Cons:

- difficult to customise generated HTML;
- code to present attachments likely to be confusing and convoluted.

### 2. Create components in Content Publisher for rendering file attachments

This would involve copying the logic and markup of attachment rendering from
Govspeak and re-creating it in Content Publisher. File attachments presented
in the context of a document would use Govspeak as their means to render,
whereas those presented outside a document would use Content Publisher
components.

Pros:

- easy to customise the HTML for Content Publisher needs;
- able to use the consistent [GOV.UK component approach][govuk-components] to
  render an attachment.

Cons:

- rendering logic and markup duplicated in two separate repositories

### 3. Both Govspeak and Content Publisher call [GOV.UK Publishing Components][govuk-publishing-components] to render file attachments

This would involve GOV.UK Publishing Components becoming the single place
used to render file attachments. Govspeak and Content Publisher would both
individually depend on this gem and call it for file attachment presentation.

Pros:

- single place for file attachment presentation logic;
- HTML of file attachment can be customised for different scenarios;
- allows wider use of the components beyond Content Publisher.

Cons:

- most complex approach for implementation, as GOV.UK Publishing Component
  releases and integration need to be managed;
- additional dependency for Govspeak.

## Decision

We decided that GOV.UK Publishing Components will store the rendering logic
for presenting File Attachment links and metadata. Govspeak and Content
Publisher will use these components for their File Attachment rendering.

We felt this approach was the one most consistent with the GOV.UK
conventions for cross-application component usage. It also allowed us
flexibility without the risks of duplication.

## Status

Accepted

## Consequences

1. Govspeak now has a dependency on GOV.UK Publishing Components. In doing so
   this has introduced a [new approach to rendering a Govspeak markdown
   extension][govspeak-approach], which may cause confusion as there were
   already multiple. On the positive side, this will allow other components to
   be rendered through Govspeak which may allow future consolidation of
   presentation logic.
2. GOV.UK Publishing Components had been using Govspeak to render markdown.
   However we needed to remove Govspeak as a dependency in order to avoid a
   cyclic dependency. Since GOV.UK Publishing Components wasn't using any
   specific Govspeak extensions we decided to replace Govspeak with
   [Kramdown](https://kramdown.gettalong.org), which incidentally is the
   library that Govspeak uses.
3. This introduces a means to render attachments for
   [publication][publication-schema] documents on the frontend of GOV.UK.
   Currently HTML is rendered by Whitehall for attachments and
   [included][attachment-html] in the [GOV.UK Content API][govuk-content-api].
   This approach has meant that data for file attachments is not extractable
   from Content API. These changes provide the foundation to replace this HTML
   with data and then convert that data into HTML when rendering the document.

[attachment-example]: https://www.gov.uk/government/publications/direct-earnings-attachments-an-employers-guide#documents-title
[govspeak]: https://github.com/alphagov/govspeak
[govuk-components]: https://docs.publishing.service.gov.uk/manual/components.html
[govuk-publishing-components]: https://github.com/alphagov/govuk_publishing_components
[govspeak-approach]: https://github.com/alphagov/govspeak/blob/3382fc774e22b8b54cce2f12b08b75ae2ba4e01a/lib/govspeak/post_processor.rb#L79-L84
[publication-schema]: https://docs.publishing.service.gov.uk/content-schemas/publication.html
[attachment-html]: https://gist.github.com/kevindew/f100d1fad981c1dcafc3f0955c3673b7#file-document-json-L404-L408
[govuk-content-api]: https://content-api.publishing.service.gov.uk/#gov-uk-content-api
