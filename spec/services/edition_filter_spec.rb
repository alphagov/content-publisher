# frozen_string_literal: true

RSpec.describe EditionFilter do
  let(:user) { build :user, organisation_content_id: "org-id" }

  describe "#editions" do
    it "orders the editions by edition last_edited_at" do
      edition1 = create(:edition, last_edited_at: 1.minute.ago)
      edition2 = create(:edition, last_edited_at: 2.minutes.ago)

      editions = EditionFilter.new(user, sort: "last_updated").editions
      expect(editions).to eq([edition2, edition1])

      editions = EditionFilter.new(user, sort: "-last_updated").editions
      expect(editions).to eq([edition1, edition2])

      editions = EditionFilter.new(user, sort: "default -last_updated").editions
      expect(editions).to eq([edition1, edition2])
    end

    it "filters the editions by title or URL" do
      edition1 = create(:edition, title: "First", base_path: "/doc_1")
      edition2 = create(:edition, title: "Second", base_path: "/doc_2")

      editions = EditionFilter.new(user, filters: { title_or_url: " " }).editions
      expect(editions).to match_array([edition1, edition2])

      editions = EditionFilter.new(user, filters: { title_or_url: "Fir" }).editions
      expect(editions).to eq([edition1])

      editions = EditionFilter.new(user, filters: { title_or_url: "_1" }).editions
      expect(editions).to eq([edition1])

      editions = EditionFilter.new(user, filters: { title_or_url: "%" }).editions
      expect(editions).to be_empty
    end

    it "filters the editions by type" do
      edition1 = create(:edition, document_type_id: "type_1")
      edition2 = create(:edition, document_type_id: "type_2")

      editions = EditionFilter.new(user, filters: { document_type: " " }).editions
      expect(editions).to match_array([edition1, edition2])

      editions = EditionFilter.new(user, filters: { document_type: "type_1" }).editions
      expect(editions).to eq([edition1])
    end

    it "filters the editions by status" do
      edition1 = create(:edition, state: "draft")
      edition2 = create(:edition, state: "submitted_for_review")

      editions = EditionFilter.new(user, filters: { status: " " }).editions
      expect(editions).to match_array([edition1, edition2])

      editions = EditionFilter.new(user, filters: { status: "non-existant" }).editions
      expect(editions).to be_empty

      editions = EditionFilter.new(user, filters: { status: "draft" }).editions
      expect(editions).to eq([edition1])
    end

    it "includes published_but_needs_2i in published status filter" do
      edition1 = create(:edition, state: "published")
      edition2 = create(:edition, state: "published_but_needs_2i")

      editions = EditionFilter.new(user, filters: { status: "published" }).editions
      expect(editions).to match_array([edition1, edition2])

      editions = EditionFilter.new(user, filters: { status: "published_but_needs_2i" }).editions
      expect(editions).to eq([edition2])
    end

    it "filters the editions by organisation" do
      edition1 = create(:edition, tags: { primary_publishing_organisation: %w[org1] })
      edition2 = create(:edition, tags: { organisations: %w[org1] })
      edition3 = create(:edition, tags: { organisations: %w[org11] })

      editions = EditionFilter.new(user, filters: { organisation: " " }).editions
      expect(editions).to match_array([edition1, edition2, edition3])

      editions = EditionFilter.new(user, filters: { organisation: "org1" }).editions
      expect(editions).to match_array([edition1, edition2])
    end

    it "ignores other kinds of filter" do
      edition1 = create(:edition)

      editions = EditionFilter.new(user, filters: { invalid: "filter" }).editions
      expect(editions).to eq([edition1])
    end

    it "paginates the editions" do
      edition1 = create(:edition, last_edited_at: 1.minute.ago)
      edition2 = create(:edition, last_edited_at: 2.minutes.ago)

      editions = EditionFilter.new(user, page: 1, per_page: 1).editions
      expect(editions).to eq([edition1])

      editions = EditionFilter.new(user, page: 2, per_page: 1).editions
      expect(editions).to eq([edition2])
    end

    context "when the edition is access limited to the primary org" do
      let!(:edition) do
        create(:edition,
               :access_limited,
               limit_type: :primary_organisation,
               tags: {
                 primary_publishing_organisation: [user.organisation_content_id],
                 organisations: %w[supporting-org],
              })
      end

      it "includes the edition if the user is in its primary org" do
        editions = EditionFilter.new(user).editions
        expect(editions).to eq([edition])
      end

      it "excludes the edition if the user is in a supporting org" do
        supporting_user = build(:user, organisation_content_id: "supporting-org")
        editions = EditionFilter.new(supporting_user).editions
        expect(editions).to be_empty
      end

      it "excludes the edition if the user is in a some other org" do
        user = build(:user, organisation_content_id: "other-org")
        editions = EditionFilter.new(user).editions
        expect(editions).to be_empty
      end

      it "excludes the edition if the user has no org" do
        editions = EditionFilter.new(build(:user)).editions
        expect(editions).to be_empty
      end
    end

    context "when the edition is access limited to tagged orgs" do
      let!(:edition) do
        create(:edition,
               :access_limited,
               limit_type: :tagged_organisations,
               tags: {
                 primary_publishing_organisation: [user.organisation_content_id],
                 organisations: %w[supporting-org],
              })
      end

      it "includes the edition if the user is in its primary org" do
        editions = EditionFilter.new(user).editions
        expect(editions).to eq([edition])
      end

      it "includes the edition if the user is in a supporting org" do
        supporting_user = build(:user, organisation_content_id: "supporting-org")
        editions = EditionFilter.new(supporting_user).editions
        expect(editions).to eq([edition])
      end

      it "excludes the edition if the user is in a some other org" do
        user = build(:user, organisation_content_id: "other-org")
        editions = EditionFilter.new(user).editions
        expect(editions).to be_empty
      end

      it "excludes the edition if the user has no org" do
        editions = EditionFilter.new(build(:user)).editions
        expect(editions).to be_empty
      end
    end

    context "when the user has an access override permission" do
      it "includes the edition" do
        edition = create(:edition, :access_limited)

        gds_user = build(:user, permissions: [
          User::ACCESS_LIMIT_OVERRIDE_PERMISSION,
        ])

        editions = EditionFilter.new(gds_user).editions
        expect(editions).to eq([edition])
      end
    end
  end

  describe "#filter_params" do
    it "returns the params used to filter" do
      params = EditionFilter.new(user, filters: { title_or_url: "title" }).filter_params
      expect(params).to eq(title_or_url: "title")
    end

    it "maintains empty params" do
      params = EditionFilter.new(user, filters: { organisation: "" }).filter_params
      expect(params).to eq(organisation: "")
    end

    it "includes sort and page if they are different to default" do
      params = EditionFilter.new(user, sort: "last_updated", page: 5).filter_params
      expect(params).to eq(sort: "last_updated", page: 5)
    end

    it "rejects page parameters less than 1" do
      params = EditionFilter.new(user, page: 0).filter_params
      expect(params).to eq({})
    end
  end
end
