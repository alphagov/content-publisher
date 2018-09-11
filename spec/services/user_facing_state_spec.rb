# frozen_string_literal: true

RSpec.describe UserFacingState do
  describe ".scope" do
    it "finds draft documents when they are not sent to review" do
      draft = create(:document,
                     publication_state: "sent_to_draft",
                     review_state: "unreviewed")
      create(:document, publication_state: "sent_to_draft", review_state: "submitted_for_review")

      expect(UserFacingState.scope(Document, "draft")).to match([draft])
    end

    it "finds submitted_for_review documents when they are sent to review" do
      create(:document, publication_state: "sent_to_draft", review_state: "reviewed")
      for_review = create(:document,
                          publication_state: "sent_to_draft",
                          review_state: "submitted_for_review")

      expect(UserFacingState.scope(Document, "submitted_for_review"))
        .to match([for_review])
    end

    it "finds published items including those marked as published_without_review" do
      create(:document, publication_state: "sent_to_draft", review_state: "unreviewed")
      published = create(:document,
                         publication_state: "sent_to_live",
                         review_state: "reviewed")
      published_but_needs_2i = create(:document,
                                      publication_state: "sent_to_live",
                                      review_state: "published_without_review")

      expect(UserFacingState.scope(Document, "published"))
        .to match([published, published_but_needs_2i])
    end

    it "can find published_but_needs_2i items" do
      create(:document, publication_state: "sent_to_live", review_state: "reviewed")
      published_but_needs_2i = create(:document,
                                      publication_state: "sent_to_live",
                                      review_state: "published_without_review")

      expect(UserFacingState.scope(Document, "published_but_needs_2i"))
        .to match([published_but_needs_2i])
    end

    it "raises an error for an unknown state" do
      expect { UserFacingState.scope(Document, "surprise") }
        .to raise_error "Unknown user_facing_state: surprise"
    end
  end

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

    it "is published if it has reviewed changes sending to live" do
      document = build(:document, publication_state: "sending_to_live", review_state: "reviewed")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("published")
    end
  end
end
