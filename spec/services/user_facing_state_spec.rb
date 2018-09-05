# frozen_string_literal: true

require "spec_helper"

RSpec.describe UserFacingState do
  describe "#to_s" do
    it "is draft if it has unpublished changes" do
      document = build(:document, publication_state: "changes_not_sent_to_draft", review_state: "unreviewed")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("draft")
    end

    it "is submitted_for_review if it has unpublished changes and 2i" do
      document = build(:document, publication_state: "changes_not_sent_to_draft", review_state: "submitted_for_review")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("submitted_for_review")
    end

    it "is draft if it has unpublished changes sent to draft" do
      document = build(:document, publication_state: "sent_to_draft")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("draft")
    end

    it "is draft if it has unpublished changes currently sending" do
      document = build(:document, publication_state: "sending_to_draft")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("draft")
    end

    it "is draft if it has unpublished changes that we can't send to draft" do
      document = build(:document, publication_state: "error_sending_to_draft")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("draft")
    end

    it "is draft if it has unpublished changes when sending to live" do
      document = build(:document, publication_state: "sending_to_live")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("draft")
    end

    it "is published_but_needs_2i if it has unreviewed changes sent to live" do
      document = build(:document, publication_state: "sent_to_live", review_state: "published_without_review")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("published_but_needs_2i")
    end

    it "is published if it has reviewed changes sent to live" do
      document = build(:document, publication_state: "sent_to_live", review_state: "reviewed")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("published")
    end
  end
end
