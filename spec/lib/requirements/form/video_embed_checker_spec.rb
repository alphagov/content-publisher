RSpec.describe Requirements::Form::VideoEmbedChecker do
  describe ".call" do
    it "returns no issues when there are none" do
      issues = described_class.call(
        title: "A title", url: "https://www.youtube.com/watch?v=hY7m5jjJ9mM",
      )

      expect(issues).to be_empty

      issues = described_class.call(
        title: "A title", url: "https://youtu.be/FdeioVndUhs",
      )

      expect(issues).to be_empty
    end

    it "returns an issue when the title is blank" do
      issues = described_class.call
      expect(issues).to have_issue(:video_embed_title, :blank)
    end

    it "returns an issue for invalid URL hosts" do
      issues = described_class.call(url: "/on-localhost")
      expect(issues).to have_issue(:video_embed_url, :non_youtube)
    end

    it "returns an issue when the URL is blank" do
      issues = described_class.call
      expect(issues).to have_issue(:video_embed_url, :blank)
    end

    it "returns an issue for an invalid URI" do
      issues = described_class.call(url: "http: youtube com")
      expect(issues).to have_issue(:video_embed_url, :non_youtube)
    end

    it "returns an issue for non-YouTube URLs" do
      issues = described_class.call(url: "http://vimeo.com")
      expect(issues).to have_issue(:video_embed_url, :non_youtube)
    end

    it "returns an issue for incomplete YouTube URLs" do
      issues = described_class.call(url: "https://www.youtube.com/watch")
      expect(issues).to have_issue(:video_embed_url, :non_youtube)
    end
  end
end
