# frozen_string_literal: true

RSpec.describe Requirements::VideoEmbedChecker do
  describe "#pre_embed_issues" do
    it "returns no issues when there are none" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(
        title: "A title", url: "https://www.youtube.com/watch?v=hY7m5jjJ9mM",
      )

      expect(issues.items).to be_empty

      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(
        title: "A title", url: "https://youtu.be/FdeioVndUhs",
      )

      expect(issues.items).to be_empty
    end

    it "returns an issue when the title is blank" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues
      form_message = issues.items_for(:video_embed_title).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.video_embed_title.blank.form_message"))
    end

    it "returns an issue for invalid URL hosts" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(url: "/on-localhost")
      form_message = issues.items_for(:video_embed_url).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.video_embed_url.non_youtube.form_message"))
    end

    it "returns an issue when the URL is blank" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues
      form_message = issues.items_for(:video_embed_url).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.video_embed_url.blank.form_message"))
    end

    it "returns an issue for non-YouTube URLs" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(url: "http://vimeo.com")
      form_message = issues.items_for(:video_embed_url).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.video_embed_url.non_youtube.form_message"))
    end

    it "returns an issue for incomplete YouTube URLs" do
      issues = Requirements::VideoEmbedChecker.new.pre_embed_issues(url: "https://www.youtube.com/watch")
      form_message = issues.items_for(:video_embed_url).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.video_embed_url.non_youtube.form_message"))
    end
  end
end
