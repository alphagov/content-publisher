# frozen_string_literal: true

RSpec.describe Requirements::VideoEmbedChecker do
  describe "#pre_embed_issues" do
    it "returns no issues when there are none" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(
        title: "A title", url: "https://www.youtube.com/watch?v=hY7m5jjJ9mM",
      )

      expect(issues).to be_empty

      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(
        title: "A title", url: "https://youtu.be/FdeioVndUhs",
      )

      expect(issues).to be_empty
    end

    it "returns an issue when the title is blank" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues
      expect(issues).to have_issue(:video_embed_title, :blank)
    end

    it "returns an issue for invalid URL hosts" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(url: "/on-localhost")
      expect(issues).to have_issue(:video_embed_url, :non_youtube)
    end

    it "returns an issue when the URL is blank" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues
      expect(issues).to have_issue(:video_embed_url, :blank)
    end

    it "returns an issue for an invalid URI" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(url: "http: youtube com")
      expect(issues).to have_issue(:video_embed_url, :non_youtube)
    end

    it "returns an issue for non-YouTube URLs" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(url: "http://vimeo.com")
      expect(issues).to have_issue(:video_embed_url, :non_youtube)
    end

    it "returns an issue for incomplete YouTube URLs" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(url: "https://www.youtube.com/watch")
      expect(issues).to have_issue(:video_embed_url, :non_youtube)
    end
  end
end
