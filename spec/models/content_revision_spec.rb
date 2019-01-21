# frozen_string_literal: true

RSpec.describe ContentRevision do
  describe "#different_to?" do
    it "is true when content data is different" do
      revision1 = build(:content_revision,
                        title: "Test",
                        contents: { "body" => "Content" })
      revision2 = build(:content_revision,
                        title: "Test",
                        contents: { "body" => "Different" })

      expect(revision1.different_to?(revision2)).to be true
    end

    it "is false when content is the same and only timestamps differ" do
      revision1 = build(:content_revision,
                        title: "Test",
                        contents: { "body" => "Content" },
                        created_at: 10.days.ago)
      revision2 = build(:content_revision,
                        title: "Test",
                        contents: { "body" => "Content" },
                        created_at: 10.weeks.ago)
      expect(revision1.different_to?(revision2)).to be false
    end
  end

  describe "#build_revision_update" do
    let(:existing_revision) { create(:content_revision) }

    it "returns the current revision if the update does not change it's content" do
      revision = existing_revision.build_revision_update(
        { title: existing_revision.title },
        build(:user),
      )

      expect(revision).to be(existing_revision)
    end

    it "returns a new revision if the update changes content" do
      revision = existing_revision.build_revision_update(
        { title: "Different title" },
        build(:user),
      )

      expect(revision).not_to be(existing_revision)
      expect(revision).to be_new_record
    end
  end
end
