RSpec.describe Edition do
  describe ".find_current" do
    it "finds an edition by id" do
      edition = create(:edition)

      expect(Edition.find_current(id: edition.id)).to eq(edition)
    end

    it "finds an edition by a document param" do
      edition = create(:edition)
      param = "#{edition.content_id}:#{edition.locale}"

      expect(Edition.find_current(document: param)).to eq(edition)
    end

    it "only finds a current edition" do
      edition = create(:edition, current: false)

      expect { Edition.find_current(id: edition.id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".political" do
    let!(:editor_political) { create(:edition, editor_political: true) }
    let!(:editor_not_political) { create(:edition, editor_political: false) }
    let!(:system_political) { create(:edition, system_political: true) }
    let!(:system_not_political) { create(:edition, system_political: false) }

    it "defaults to scoping to only political editions" do
      expect(Edition.political)
        .to contain_exactly(editor_political, system_political)
    end

    it "can be passed false to scope to non political editions" do
      expect(Edition.political(false))
        .to contain_exactly(editor_not_political, system_not_political)
    end
  end

  describe ".history_mode" do
    before { populate_default_government_bulk_data }

    let!(:political_past_government) { create(:edition, :political, government: past_government) }
    let!(:political_current_government) { create(:edition, :political, government: current_government) }
    let!(:political_no_government) { create(:edition, :political, government: nil) }
    let!(:not_political) { create(:edition, :not_political) }

    it "defaults to scoping to only history mode editions" do
      expect(Edition.history_mode)
        .to contain_exactly(political_past_government)
    end

    it "can be passed false to scope to non history mode editions" do
      expect(Edition.history_mode(false))
        .to contain_exactly(political_current_government, political_no_government, not_political)
    end
  end

  describe "#political?" do
    it "returns editor political when that is set" do
      political_edition = build(:edition,
                                editor_political: true,
                                system_political: true)
      not_political_edition = build(:edition,
                                    editor_political: false,
                                    system_political: true)
      expect(political_edition).to be_political
      expect(not_political_edition).not_to be_political
    end

    it "returns system political when editor political isn't set" do
      political_edition = build(:edition,
                                editor_political: nil,
                                system_political: true)
      not_political_edition = build(:edition,
                                    editor_political: nil,
                                    system_political: false)
      expect(political_edition).to be_political
      expect(not_political_edition).not_to be_political
    end
  end

  describe "#history_mode?" do
    before { populate_default_government_bulk_data }

    it "returns true when political and associated with a previous government" do
      edition = build(:edition, :political, government: past_government)
      expect(edition.history_mode?).to be(true)
    end

    it "returns false when the edition isn't political" do
      edition = build(:edition, :not_political)
      expect(edition.history_mode?).to be(false)
    end

    it "returns false when the edition isn't associated with a government" do
      edition = build(:edition, :political, government: nil)
      expect(edition.history_mode?).to be(false)
    end

    it "returns false when the edition is political and associated with the current government" do
      edition = build(:edition, :political, government: current_government)
      expect(edition.history_mode?).to be(false)
    end
  end

  describe "#government" do
    it "returns nil when government_id isn't set" do
      edition = build(:edition, government_id: nil)
      expect(edition.government).to be_nil
    end

    it "returns a government when one matches the id" do
      government = build(:government)
      populate_government_bulk_data(government)

      edition = build(:edition, government_id: government.content_id)
      expect(edition.government).to eq(government)
    end

    it "raises an error when no government matches the id" do
      edition = build(:edition, government_id: SecureRandom.uuid)
      expect { edition.government }.to raise_error(RuntimeError)
    end
  end

  describe "#public_first_published_at" do
    it "returns backdate when that is set" do
      freeze_time do
        edition = build(:edition, backdated_to: 1.year.ago, first_published_at: 1.week.ago)
        expect(edition.public_first_published_at).to eq(1.year.ago)
      end
    end

    it "returns first published date when backdate isn't set" do
      freeze_time do
        edition = build(:edition, backdated_to: nil, first_published_at: 1.week.ago)
        expect(edition.public_first_published_at).to eq(1.week.ago)
      end
    end

    it "returns nil when it is not backdated or first published" do
      edition = build(:edition, backdated_to: nil, first_published_at: nil)
      expect(edition.public_first_published_at).to be_nil
    end
  end

  describe "#access_limit_organisation_ids" do
    context "when the limit is to primary orgs" do
      let(:edition) do
        build(:edition,
              :access_limited,
              limit_type: :primary_organisation,
              tags: {
                primary_publishing_organisation: %w[primary-org],
                organisations: %w[supporting-org],
              })
      end

      it "returns just the primary org id" do
        ids = edition.access_limit_organisation_ids
        expect(ids).to eq(%w[primary-org])
      end
    end

    context "when the limit is to tagged orgs" do
      let(:edition) do
        build(:edition,
              :access_limited,
              limit_type: :tagged_organisations,
              tags: {
                primary_publishing_organisation: %w[primary-org],
                organisations: %w[supporting-org],
              })
      end

      it "returns the primary and supporting orgs" do
        ids = edition.access_limit_organisation_ids
        expect(ids).to match_array(%w[primary-org supporting-org])
      end
    end
  end

  describe "#add_edition_editor" do
    it "adds an edition user if they are not already listed as an editor" do
      user = build(:user)
      edition = build(:edition)

      edition.add_edition_editor(user)
      expect(edition.editors).to include(user)
    end

    it "does not add an edition user if they are already listed as an editor" do
      user = build(:user)
      edition = build(:edition, editors: [user])

      expect { edition.add_edition_editor(user) }
          .not_to(change { edition.editors })
    end
  end
end
