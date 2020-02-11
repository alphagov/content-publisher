RSpec.describe PreviewDraftEditionService::Payload do
  describe "#payload" do
    it "generates a payload for the publishing API" do
      document_type = build(:document_type)
      edition = build(:edition, document_type: document_type)

      payload = PreviewDraftEditionService::Payload.new(edition).payload

      payload_hash = {
        document_type: document_type.id,
        links: { government: [], organisations: [] },
        locale: edition.locale,
        publishing_app: "content-publisher",
        rendering_app: nil,
        schema_name: nil,
      }
      expect(payload).to match a_hash_including(payload_hash)
      expect(payload).not_to include(:first_published_at)
    end

    it "specifies an auth bypass ID for anonymous previews" do
      edition = build(:edition)
      preview_auth_bypass = instance_double(PreviewAuthBypass, auth_bypass_id: "id")
      allow(PreviewAuthBypass).to receive(:new).and_return(preview_auth_bypass)
      payload = PreviewDraftEditionService::Payload.new(edition).payload
      expect(payload[:auth_bypass_ids]).to eq(%w[id])
    end

    it "specifies organisations when the edition is access limited" do
      edition = build(:edition, :access_limited)
      allow(edition).to receive(:access_limit_organisation_ids).and_return(%w[org-id])
      payload = PreviewDraftEditionService::Payload.new(edition).payload
      expect(payload[:access_limited][:organisations]).to eq %w[org-id]
    end

    it "includes primary_publishing_organisation in organisations links" do
      organisation = build(:tag_field, :primary_publishing_organisation)
      document_type = build(:document_type, tags: [organisation])
      edition = build(:edition,
                      document_type: document_type,
                      tags: { primary_publishing_organisation: %w[my-org-id],
                              organisations: %w[other-org-id] })

      payload = PreviewDraftEditionService::Payload.new(edition).payload

      expect(payload[:links]).to match a_hash_including(
        primary_publishing_organisation: %w[my-org-id],
        organisations: %w[my-org-id other-org-id],
      )
    end

    it "ensures the organisation links are unique" do
      organisation = build(:tag_field, :primary_publishing_organisation)
      document_type = build(:document_type, tags: [organisation])
      edition = build(:edition,
                      document_type: document_type,
                      tags: { primary_publishing_organisation: %w[my-org-id],
                              organisations: %w[my-org-id] })

      payload = PreviewDraftEditionService::Payload.new(edition).payload

      expect(payload[:links][:organisations]).to eq %w[my-org-id]
    end

    it "converts role appointment links to role and person links" do
      role_appointment_id = SecureRandom.uuid
      role_appointments = build(:tag_field, type: "multi_tag", id: "role_appointments")
      document_type = build(:document_type, tags: [role_appointments])
      edition = build(:edition,
                      document_type: document_type,
                      tags: { role_appointments: [role_appointment_id] })

      person_id = SecureRandom.uuid
      role_id = SecureRandom.uuid
      stub_publishing_api_has_links(
        content_id: role_appointment_id,
        links: { person: [person_id], role: [role_id] },
      )

      payload = PreviewDraftEditionService::Payload.new(edition).payload

      expect(payload[:links]).to match a_hash_including(
        roles: [role_id],
        people: [person_id],
      )
    end

    it "delegates to document type fields for contents" do
      body_field = instance_double(DocumentType::BodyField,
                                   payload: { details: { body: "body" } })

      document_type = build(:document_type, contents: [body_field])
      edition = build(:edition, document_type: document_type)
      payload = PreviewDraftEditionService::Payload.new(edition).payload
      expect(payload[:details][:body]).to eq("body")
    end

    it "includes a lead image if present" do
      image_revision = build(:image_revision,
                             :on_asset_manager,
                             alt_text: "image alt text",
                             caption: "image caption",
                             credit: "image credit")

      document_type = build(:document_type, images: true)

      edition = build(:edition,
                      document_type: document_type,
                      lead_image_revision: image_revision)

      payload = PreviewDraftEditionService::Payload.new(edition).payload

      payload_hash = {
        url: image_revision.asset_url("300"),
        high_resolution_url: image_revision.asset_url("high_resolution"),
        alt_text: "image alt text",
        caption: "image caption",
        credit: "image credit",
      }

      expect(payload[:details][:image]).to match a_hash_including(payload_hash)
    end

    it "includes the political status of the edition" do
      political_edition = build(:edition, :political)
      payload = PreviewDraftEditionService::Payload.new(political_edition).payload
      expect(payload[:details][:political]).to be true

      not_political_edition = build(:edition, :not_political)
      payload = PreviewDraftEditionService::Payload.new(not_political_edition).payload
      expect(payload[:details][:political]).to be false
    end

    it "includes government when one is present" do
      government = build(:government)
      populate_government_bulk_data(government)

      edition = build(:edition, government_id: government.content_id)

      payload = PreviewDraftEditionService::Payload.new(edition).payload

      expect(payload[:links][:government]).to eq [government.content_id]
    end

    it "includes a change note if the update type is 'major'" do
      edition = build(:edition,
                      update_type: "major",
                      change_note: "A change note")
      payload = PreviewDraftEditionService::Payload.new(edition).payload

      expect(payload).to match a_hash_including(change_note: "A change note")
    end

    it "does not include a change note if the update type is 'minor'" do
      edition = build(:edition,
                      update_type: "minor",
                      change_note: "A change note")
      payload = PreviewDraftEditionService::Payload.new(edition).payload

      expect(payload).not_to match a_hash_including(change_note: "A change note")
    end

    it "includes first_published_at if the edition has a backdated_to value" do
      date = Time.current.yesterday
      revision = build(:revision, backdated_to: date)
      edition = build(:edition, revision: revision)
      payload = PreviewDraftEditionService::Payload.new(edition).payload

      expect(payload).to match a_hash_including(first_published_at: date)
    end

    it "include public_updated_at if the edition has backdated_to and is a first edition" do
      date = Time.current.yesterday
      revision = build(:revision, backdated_to: date)
      edition = build(:edition, revision: revision, number: 1)
      payload = PreviewDraftEditionService::Payload.new(edition).payload

      expect(payload).to match a_hash_including(public_updated_at: date)
    end

    it "includes bulk_publishing and sets the update to republish if the edition is being republished" do
      edition = build(:edition)
      payload = PreviewDraftEditionService::Payload.new(edition, republish: true).payload

      expect(payload).to match a_hash_including(
        update_type: "republish",
        bulk_publishing: true,
      )
    end
  end
end
