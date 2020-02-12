module WhitehallImporter
  class IntegrityChecker::BodyTextCheck
    attr_reader :proposed_body_text, :publishing_api_body_text

    def initialize(proposed_body_text, publishing_api_body_text)
      @proposed_body_text = proposed_body_text
      @publishing_api_body_text = publishing_api_body_text
    end

    def sufficiently_similar?
      proposed_body = remove_attachment_file_size(proposed_body_text)
      publishing_api_body = remove_attachment_file_size(publishing_api_body_text)
      Sanitize.clean(publishing_api_body).squish == Sanitize.clean(proposed_body).squish
    end

  private

    def remove_attachment_file_size(body)
      file_size_selector = ".attachment-inline .file-size, .gem-c-attachment-link .gem-c-attachment-link__attribute:nth-of-type(2)"
      remove_html_elements(body, file_size_selector)
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
