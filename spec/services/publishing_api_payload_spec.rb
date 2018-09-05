# frozen_string_literal: true

RSpec.describe PublishingApiPayload do
  describe "#payload" do
    it "generates a payload for the publishing API" do
      document_type_schema = build(:document_type_schema)
      document = build(:document, document_type: document_type_schema.id, title: "Some title", summary: "document summary", base_path: "/foo/bar/baz")

      payload = PublishingApiPayload.new(document).payload

      payload_hash = {
        "base_path" => "/foo/bar/baz",
        "description" => "document summary",
        "document_type" => document_type_schema.id,
        "links" => { "organisations" => [] },
        "locale" => document.locale,
        "publishing_app" => "content-publisher",
        "rendering_app" => nil,
        "routes" => [{ "path" => "/foo/bar/baz", "type" => "exact" }],
        "schema_name" => nil,
        "title" => "Some title",
      }
      expect(payload).to match a_hash_including(payload_hash)
    end

    it "includes primary_publishing_organisation in organisations links" do
      organisation_schema = build(:tag_schema, type: "single_tag", id: "primary_publishing_organisation")
      document_type_schema = build(:document_type_schema, tags: [organisation_schema])
      document = build(:document, document_type: document_type_schema.id, tags: {
                         primary_publishing_organisation: ["my-org-id"],
                         organisations: ["other-org-id"],
                       })

      payload = PublishingApiPayload.new(document).payload

      payload_hash = {
        "links" => {
          "primary_publishing_organisation" => ["my-org-id"],
          "organisations" => ["my-org-id", "other-org-id"],
        },
      }
      expect(payload).to match a_hash_including(payload_hash)
    end

    it "ensures the organisation links are unique" do
      organisation_schema = build(:tag_schema, type: "single_tag", id: "primary_publishing_organisation")
      document_type_schema = build(:document_type_schema, tags: [organisation_schema])
      document = build(:document, document_type: document_type_schema.id, tags: {
                         primary_publishing_organisation: ["my-org-id"],
                         organisations: ["my-org-id"],
                       })

      payload = PublishingApiPayload.new(document).payload

      payload_hash = {
        "links" => {
          "primary_publishing_organisation" => ["my-org-id"],
          "organisations" => ["my-org-id"],
        },
      }
      expect(payload).to match a_hash_including(payload_hash)
    end

    it "transforms Govspeak before sending it to the publishing-api" do
      body_field_schema = build(:field_schema, type: "govspeak", id: "body")
      document_type_schema = build(:document_type_schema, contents: [body_field_schema])
      document = build(:document, document_type: document_type_schema.id, contents: { body: "Hey **buddy**!" })

      payload = PublishingApiPayload.new(document).payload

      expect(payload["details"]["body"]).to eq("<p>Hey <strong>buddy</strong>!</p>\n")
    end
  end
end
