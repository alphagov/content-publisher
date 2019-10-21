# frozen_string_literal: true

RSpec.describe PreviewService::Payload do
  describe "#payload" do
    it "generates a payload for the publishing API" do
      document_type = build(:document_type)
      edition = build(:edition,
                      document_type_id: document_type.id,
                      title: "Some title",
                      summary: "document summary",
                      base_path: "/foo/bar/baz")

      payload = PreviewService::Payload.new(edition).payload

      payload_hash = {
        "base_path" => "/foo/bar/baz",
        "description" => "document summary",
        "document_type" => document_type.id,
        "links" => { "organisations" => [] },
        "locale" => edition.locale,
        "publishing_app" => "content-publisher",
        "rendering_app" => nil,
        "routes" => [{ "path" => "/foo/bar/baz", "type" => "exact" }],
        "schema_name" => nil,
        "title" => "Some title",
      }
      expect(payload).to match a_hash_including(payload_hash)
      expect(payload).not_to include("first_published_at")
    end

    it "specifies an auth bypass ID for anonymous previews" do
      edition = build(:edition)
      allow_any_instance_of(PreviewAuthBypass).to receive(:auth_bypass_id) { "id" }
      payload = PreviewService::Payload.new(edition).payload
      expect(payload["auth_bypass_ids"]).to eq(%w[id])
    end

    it "specifies organistions when the edition is access limited" do
      edition = build(:edition, :access_limited)
      allow(edition).to receive(:access_limit_organisation_ids) { %w[org-id] }
      payload = PreviewService::Payload.new(edition).payload
      expect(payload["access_limited"]["organisations"]).to eq %w[org-id]
    end

    it "includes primary_publishing_organisation in organisations links" do
      organisation = build(:tag_field, type: "single_tag", id: "primary_publishing_organisation")
      document_type = build(:document_type, tags: [organisation])
      edition = build(:edition,
                      document_type_id: document_type.id,
                      tags: { primary_publishing_organisation: %w[my-org-id],
                              organisations: %w[other-org-id] })

      payload = PreviewService::Payload.new(edition).payload

      payload_hash = {
        "links" => {
          "primary_publishing_organisation" => %w[my-org-id],
          "organisations" => %w[my-org-id other-org-id],
        },
      }
      expect(payload).to match a_hash_including(payload_hash)
    end

    it "ensures the organisation links are unique" do
      organisation = build(:tag_field, type: "single_tag", id: "primary_publishing_organisation")
      document_type = build(:document_type, tags: [organisation])
      edition = build(:edition,
                      document_type_id: document_type.id,
                      tags: { primary_publishing_organisation: %w[my-org-id],
                              organisations: %w[my-org-id] })

      payload = PreviewService::Payload.new(edition).payload

      payload_hash = {
        "links" => {
          "primary_publishing_organisation" => %w[my-org-id],
          "organisations" => %w[my-org-id],
        },
      }
      expect(payload).to match a_hash_including(payload_hash)
    end

    it "converts role appointment links to role and person links" do
      role_appointment_id = SecureRandom.uuid
      role_appointments = build(:tag_field, type: "multi_tag", id: "role_appointments")
      document_type = build(:document_type, tags: [role_appointments])
      edition = build(:edition,
                      document_type_id: document_type.id,
                      tags: { role_appointments: [role_appointment_id] })

      person_id = SecureRandom.uuid
      role_id = SecureRandom.uuid
      stub_publishing_api_has_links(
        "content_id" => role_appointment_id,
        "links" => { "person" => [person_id], "role" => [role_id] },
      )

      payload = PreviewService::Payload.new(edition).payload

      expect(payload["links"]).to match a_hash_including(
        "roles" => [role_id],
        "people" => [person_id],
      )
    end

    it "transforms Govspeak before sending it to the publishing-api" do
      body_field = build(:field, type: "govspeak", id: "body")
      document_type = build(:document_type, contents: [body_field])
      edition = build(:edition,
                      document_type_id: document_type.id,
                      contents: { body: "Hey **buddy**!" })

      payload = PreviewService::Payload.new(edition).payload

      expect(payload["details"]["body"]).to eq("<p>Hey <strong>buddy</strong>!</p>\n")
    end

    it "includes a lead image if present" do
      image_revision = build(:image_revision,
                             :on_asset_manager,
                             alt_text: "image alt text",
                             caption: "image caption",
                             credit: "image credit")

      document_type = build(:document_type, images: true)

      edition = build(:edition,
                      document_type_id: document_type.id,
                      lead_image_revision: image_revision)

      payload = PreviewService::Payload.new(edition).payload

      payload_hash = {
        "url" => image_revision.asset_url("300"),
        "high_resolution_url" => image_revision.asset_url("high_resolution"),
        "alt_text" => "image alt text",
        "caption" => "image caption",
        "credit" => "image credit",
      }

      expect(payload["details"]["image"]).to match a_hash_including(payload_hash)
    end

    it "includes a change note if the update type is 'major'" do
      edition = create(:edition,
                       update_type: "major",
                       change_note: "A change note")
      payload = PreviewService::Payload.new(edition).payload

      expect(payload).to match a_hash_including("change_note" => "A change note")
    end

    it "does not include a change note if the update type is 'minor'" do
      edition = create(:edition,
                       update_type: "minor",
                       change_note: "A change note")
      payload = PreviewService::Payload.new(edition).payload

      expect(payload).not_to match a_hash_including("change_note" => "A change note")
    end

    it "includes first_published_at if the edition has a backdated_to value" do
      date = Time.current.yesterday
      revision = build(:revision, backdated_to: date)
      edition = create(:edition, revision: revision)
      payload = PreviewService::Payload.new(edition).payload

      expect(payload).to match a_hash_including("first_published_at" => date)
    end

    it "include public_updated_at if the edition has backdated_to and is a first edition" do
      date = Time.current.yesterday
      revision = build(:revision, backdated_to: date)
      edition = create(:edition, revision: revision, number: 1)
      payload = PreviewService::Payload.new(edition).payload

      expect(payload).to match a_hash_including("public_updated_at" => date)
    end
  end
end
