RSpec.describe WhitehallImporter::IntegrityChecker::BodyTextCheck do
  describe "#sufficiently_similar?" do
    it "retuns true if the proposed payload matches" do
      integrity_check = described_class.new("Some text", "Some text")
      expect(integrity_check.sufficiently_similar?).to be true
    end

    it "returns true when the body text whitespace does not match" do
      integrity_check = described_class.new("Some text", "Some     text")
      expect(integrity_check.sufficiently_similar?).to be true
    end

    it "returns true when the HTML does not match" do
      integrity_check = described_class.new("<b>Some text</b>", "Some text")
      expect(integrity_check.sufficiently_similar?).to be true
    end

    it "returns true even if there is a mismatch in an attachment link filesize" do
      proposed_body = %(
        <span class="gem-c-attachment-link">
          <a class="govuk-link" href="filename.pdf" target="_blank">Test File</a>
          (
            <span class="gem-c-attachment-link__attribute">
              <abbr title="Portable Document Format" class="gem-c-attachment-link__abbr">PDF</abbr></span>,
            <span class="gem-c-attachment-link__attribute">391 KB</span>,
            <span class="gem-c-attachment-link__attribute">9 pages</span>
          )
        </span>
      )

      publishing_api_body = %(
        <span class="attachment-inline">
          <a href="/filename.pdf">Test File</a>
          (
            <span class="type">PDF</span>,
            <span class="file-size">391KB</span>,
            <span class="page-length">9 pages</span>
          )
        </span>
      )

      integrity_check = described_class.new(proposed_body, publishing_api_body)
      expect(integrity_check.sufficiently_similar?).to be true
    end

    it "returns true even if there is a mismatch in an attachment filesize" do
      proposed_body = %(
        <p class="gem-c-attachment__metadata">
          <span class="gem-c-attachment__attribute">
            <abbr title="Portable Document Format" class="gem-c-attachment__abbr">PDF</abbr>
          </span>,
          <span class="gem-c-attachment__attribute">391 KB</span>,
          <span class="gem-c-attachment__attribute">9 pages</span>
        </p>
      )

      publishing_api_body = %(
        <p class="metadata">
          <span class="type">
            <abbr title="Portable Document Format">PDF</abbr>
          </span>,
          <span class="file-size">391KB</span>,
          <span class="page-length">9 pages</span>
        </p>
      )

      integrity_check = described_class.new(proposed_body, publishing_api_body)
      expect(integrity_check.sufficiently_similar?).to be true
    end

    it "returns false when the body text doesn't match" do
      integrity_check = described_class.new("Some text", "Some different text")
      expect(integrity_check.sufficiently_similar?).to be false
    end

    it "returns true when both body texts include an accessibility notice" do
      integrity_check = described_class.new(
        proposed_body_with_accessibility_notice,
        publishing_api_body_with_accessibility_notice,
      )
      expect(integrity_check.sufficiently_similar?).to be true
    end

    it "returns true when only one body text includes an accessibility notice" do
      publishing_api_body = %(
        <h2 class="title">
          <a href="https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/294830/Improving_mat_care.pdf" class="govuk-link">
            Improving Maternity Care Settings Funding Allocations
          </a>
        </h2>
      )

      integrity_check = described_class.new(
        proposed_body_with_accessibility_notice,
        publishing_api_body,
      )
      expect(integrity_check.sufficiently_similar?).to be true
    end
  end

  def proposed_body_with_accessibility_notice
    %(
      <div class="gem-c-attachment__details">
        <h2 class="gem-c-attachment__title">
          <a class="govuk-link gem-c-attachment__link" target="_self" href="\">Improving Maternity Care Settings Funding Allocations</a>
        </h2>
        <p class="gem-c-attachment__metadata">
          This file may not be suitable for users of assistive technology.
        </p>
        <details class="gem-c-details govuk-details govuk-!-margin-bottom-3" data-module="govuk-details">
          <summary class="govuk-details__summary" data-details-track-click>
            <span class="govuk-details__summary-text">
              Request an accessible format.
            </span>
          </summary>
          <div class="govuk-details__text">
            If you use assistive technology (such as a screen reader) and need a version of this document in a more accessible format, please email <a href=\"mailto:publications@dhsc.gov.uk\" target=\"_blank\" class=\"govuk-link\">publications@dhsc.gov.uk</a>. Please tell us what format you need. It will help us if you say what assistive technology you use.
          </div>
        </details>
      </div>
    )
  end

  def publishing_api_body_with_accessibility_notice
    %(
      <h2 class="title">
        <a href="https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/294830/Improving_mat_care.pdf" class="govuk-link">
          Improving Maternity Care Settings Funding Allocations
        </a>
      </h2>
      <h2>
        This file may not be suitable for users of assistive technology.
        <a class="govuk-link" href="#attachment-4080725-accessibility-request" data-controls="attachment-4080725-accessibility-request" data-expanded="false">Request an accessible format.</a>
      </h2>
      <p id="attachment-4080725-accessibility-request" class="js-hidden">
        If you use assistive technology (such as a screen reader) and need a version of this document in a more accessible format, please email <a href=\"mailto:accessibleformats@digital.cabinet-office.gov.uk?body=Details%20of%20document%20required%3A%0A%0A%20%20Title%3A%20Peters%20attachment%0A%20%20Original%20format%3A%20pdf%0A%0APlease%20tell%20us%3A%0A%0A%20%201.%20What%20makes%20this%20format%20unsuitable%20for%20you%3F%0A%20%202.%20What%20format%20you%20would%20prefer%3F%0A%20%20%20%20%20%20&amp;subject=Request%20for%20%27Peters%20attachment%27%20in%20an%20alternative%20format\" class=\"govuk-link\">accessibleformats@digital.cabinet-office.gov.uk</a>.
        Please tell us what format you need. It will help us if you say what assistive technology you use.
      </p>
    )
  end
end
