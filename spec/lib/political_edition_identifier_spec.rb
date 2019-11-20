# frozen_string_literal: true

RSpec.describe PoliticalEditionIdentifier do
  describe ".policical_organisation_ids" do
    it "returns an array of content_ids" do
      uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
      organisation_ids = PoliticalEditionIdentifier.political_organisation_ids
      expect(organisation_ids).not_to be_empty
      expect(organisation_ids).to all match(uuid_regex)
    end
  end

  describe "#political?" do
    let(:document_type) do
      primary_organisation_field = build(:tag_field,
                                         type: "single_tag",
                                         id: "primary_publishing_organisation")
      organisations_field = build(:tag_field,
                                  type: "multi_tag",
                                  id: "organisations")
      role_appointments_field = build(:tag_field,
                                      type: "multi_tag",
                                      id: "role_appointments")

      build(:document_type, tags: [primary_organisation_field,
                                   organisations_field,
                                   role_appointments_field])
    end

    it "returns true when an edition is associated with a role appointment" do
      edition = build(:edition,
                      document_type_id: document_type.id,
                      tags: { role_appointments: [SecureRandom.uuid] })
      expect(PoliticalEditionIdentifier.new(edition).political?).to be true
    end

    it "returns true when an editions primary publishing organisation is political" do
      political_organisation_id = SecureRandom.uuid
      allow(PoliticalEditionIdentifier)
        .to receive(:political_organisation_ids)
        .and_return([political_organisation_id])

      edition = build(:edition,
                      document_type_id: document_type.id,
                      tags: { primary_publishing_organisation: [political_organisation_id] })
      expect(PoliticalEditionIdentifier.new(edition).political?).to be true
    end

    it "returns true when an editions supporting organisation is political" do
      political_organisation_id = SecureRandom.uuid
      allow(PoliticalEditionIdentifier)
        .to receive(:political_organisation_ids)
        .and_return([political_organisation_id])

      edition = build(:edition,
                      document_type_id: document_type.id,
                      tags: { primary_publishing_organisation: [SecureRandom.uuid],
                              organisations: [political_organisation_id] })

      expect(PoliticalEditionIdentifier.new(edition).political?).to be true
    end

    it "returns false when an edition is not associated with a role appointment or a political organisation" do
      edition = build(:edition,
                      document_type_id: document_type.id,
                      tags: { primary_publishing_organisation: [SecureRandom.uuid] })
      expect(PoliticalEditionIdentifier.new(edition).political?).to be false
    end
  end
end
