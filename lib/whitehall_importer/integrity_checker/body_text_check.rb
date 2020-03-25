module WhitehallImporter
  class IntegrityChecker::BodyTextCheck
    attr_reader :proposed_body_text, :publishing_api_body_text

    ACCESSIBLE_FORMAT_NOTICE = / This file may not be suitable for users of assistive technology. (.*) It will help us if you say what assistive technology you use./.freeze

    def initialize(proposed_body_text, publishing_api_body_text)
      @proposed_body_text = proposed_body_text
      @publishing_api_body_text = publishing_api_body_text
    end

    def sufficiently_similar?
      proposed_body = processed_body(proposed_body_text)
      publishing_api_body = processed_body(publishing_api_body_text)

      proposed_body == publishing_api_body
    end

  private

    def processed_body(body_text)
      processed_body = remove_attachment_file_size(body_text)
      remove_accessible_format_notice(Sanitize.clean(processed_body).squish)
    end

    def remove_accessible_format_notice(sanitized_body)
      sanitized_body.gsub(ACCESSIBLE_FORMAT_NOTICE, "")
    end

    def remove_attachment_file_size(body)
      file_size_selectors = [
        ".attachment-inline .file-size",
        ".metadata .file-size",
        ".gem-c-attachment-link .gem-c-attachment-link__attribute:nth-of-type(2)",
        ".gem-c-attachment__metadata .gem-c-attachment__attribute:nth-of-type(2)",
      ]

      remove_html_elements(body, file_size_selectors.join(","))
    end

    def remove_html_elements(body, selector)
      doc = Nokogiri.HTML(body)
      doc.search(selector).each do |el|
        el.replace("")
      end
      doc.to_html
    end
  end
end
