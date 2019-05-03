# frozen_string_literal: true

RSpec.describe GovspeakDocument::InAppOptions do
  describe "#to_h" do
    it "returns the local representation of the image" do
      image_revision = build(:image_revision,
                             alt_text: "Some alt text",
                             caption: "An optional caption",
                             credit: "An optional credit",
                             filename: "filename.png")
      edition = build(:edition,
                      image_revisions: [image_revision])

      in_app_options = GovspeakDocument::InAppOptions.new("govspeak", edition)
      actual_image_options = in_app_options.to_h[:images].first
      expect(actual_image_options[:alt_text]).to eq("Some alt text")
      expect(actual_image_options[:caption]).to eq("An optional caption")
      expect(actual_image_options[:credit]).to eq("An optional credit")
      expect(actual_image_options[:url]).to match("/representations")
      expect(actual_image_options[:url]).to match("filename.png")
      expect(actual_image_options[:id]).to eq("filename.png")
    end

    it "returns the local representation of a file attachment" do
      file_attachment_revision = build(:file_attachment_revision,
                                       fixture: "13kb-1-page-attachment.pdf",
                                       filename: "13kb-1-page-attachment.pdf",
                                       title: "A title",
                                       number_of_pages: 1)
      edition = build(:edition,
                      file_attachment_revisions: [file_attachment_revision])

      in_app_options = GovspeakDocument::InAppOptions.new("govspeak", edition)
      actual_attachment_options = in_app_options.to_h[:attachments].first

      expect(actual_attachment_options[:filename]).to eq("13kb-1-page-attachment.pdf")
      expect(actual_attachment_options[:title]).to eq("A title")
      expect(actual_attachment_options[:content_type]).to eq("application/pdf")
      expect(actual_attachment_options[:number_of_pages]).to eq(1)
      expect(actual_attachment_options[:file_size]).to eq(13264)
      # TODO add url expectation when we have an internal preview URL
      expect(actual_attachment_options[:id]).to eq("13kb-1-page-attachment.pdf")
    end
  end
end
