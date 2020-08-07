RSpec.describe WhitehallImporter::IntegrityChecker do
  let(:document_type) do
    build(
      :document_type,
      :with_lead_image,
      contents: [
        DocumentType::TitleAndBasePathField.new,
        DocumentType::SummaryField.new,
        DocumentType::BodyField.new,
      ],
      tags: [
        DocumentType::PrimaryPublishingOrganisationField.new,
        DocumentType::OrganisationsField.new,
      ],
    )
  end

  describe "#valid?" do
    let(:status) { :published }
    let(:state) { :published }
    let(:edition) do
      build(:edition,
            status,
            state: state,
            document_type: document_type,
            published_at: "2020-03-11 12:00 UTC",
            document: create(:document, first_published_at: "2020-03-11 12:00:45 UTC"),
            tags: {
              primary_publishing_organisation: [SecureRandom.uuid],
              organisations: [SecureRandom.uuid],
            })
    end
    let(:publishing_api_item) do
      default_publishing_api_item(edition,
                                  public_updated_at: "2020-03-11T12:00:00Z",
                                  state_history: { "1" => "published" },
                                  publication_state: "published",
                                  details: {
                                    body: GovspeakDocument.new(edition.contents["body"], edition).payload_html,
                                    first_public_at: "2020-03-11T12:00:00.000+00:00",
                                  },
                                  links: {
                                    primary_publishing_organisation: edition.tags["primary_publishing_organisation"].to_a,
                                    organisations: edition.tags["organisations"].to_a + edition.tags["primary_publishing_organisation"].to_a,
                                  })
    end
    let(:integrity_check) { described_class.new(edition) }

    let(:explanation) { "This has been moved" }
    let(:html_explanation) do
      "#{explanation} <a href=\"https://www.gov.uk/elsewhere\">elsewhere</a>"
    end

    let(:markdown_explanation) do
      "#{explanation} [elsewhere](https://www.gov.uk/elsewhere)"
    end

    it "returns true if there aren't any problems for edition without image or attachment" do
      stub_publishing_api_has_item(publishing_api_item)

      expect(integrity_check.valid?).to be true
    end

    it "returns true if the Publishing API image caption is nil but the imported image caption is an empty string" do
      image_revision = create(:image_revision, caption: "")
      edition.revision.image_revisions = [image_revision]
      edition.revision.lead_image_revision = image_revision

      publishing_api_item[:details][:image] = {
        caption: nil,
      }
      stub_publishing_api_has_item(publishing_api_item)

      expect(integrity_check.valid?).to be true
    end

    it "returns true if the Publishing API image is a placeholder and the imported edition has no image" do
      publishing_api_item[:details][:image] = {
        alt_text: "",
      }
      stub_publishing_api_has_item(publishing_api_item)

      expect(integrity_check.valid?).to be true
    end

    it "returns true if first_published_at times match" do
      publishing_api_item[:details][:first_public_at] = "2020-03-11T12:00:00.000+00:00"
      stub_publishing_api_has_item(publishing_api_item)

      expect(integrity_check.valid?).to be true
    end

    it "returns true if public_updated_at times match" do
      publishing_api_item[:public_updated_at] = "2020-03-11T12:00:45Z"
      stub_publishing_api_has_item(publishing_api_item)

      expect(integrity_check.valid?).to be true
    end

    it "compares against organisations in linkset links if there no edition links" do
      publishing_api_item[:links] = {}
      stub_publishing_api_has_item(publishing_api_item)

      stub_publishing_api_has_links(
        content_id: edition.content_id,
        links: {
          primary_publishing_organisation: edition.tags["primary_publishing_organisation"].to_a,
          organisations: edition.tags["organisations"].to_a + edition.tags["primary_publishing_organisation"].to_a,
        },
      )

      expect(integrity_check.valid?).to be true
    end

    it "returns true when there is no change history" do
      publishing_api_item[:details] = publishing_api_item[:details].except(:change_history)
      stub_publishing_api_has_item(publishing_api_item)

      expect(integrity_check.valid?).to be true
    end

    context "when checking an edition that is published_but_needs_2i" do
      let(:state) { :published_but_needs_2i }

      it "returns true if states are equivalent" do
        stub_publishing_api_has_item(publishing_api_item)

        expect(integrity_check.valid?).to be true
      end
    end

    context "when checking an edition that isn't live" do
      let(:status) { :scheduled }

      it "returns true even if the public_updated_at times don't match" do
        publishing_api_item[:public_updated_at] = "2019-02-11T09:30:00Z"
        publishing_api_item[:publication_state] = "draft"
        publishing_api_item[:details] = publishing_api_item[:details].except(:change_history)
        stub_publishing_api_has_item(publishing_api_item)

        expect(integrity_check.valid?).to be true
      end
    end

    it "returns true if withdrawn data matches the Publishing API" do
      withdrawal = build(:withdrawal, public_explanation: markdown_explanation)
      withdrawn_edition = build(:edition,
                                :withdrawn,
                                document_type: document_type,
                                first_published_at: Date.yesterday.noon,
                                withdrawal: withdrawal)

      first_published_at = withdrawn_edition.document.first_published_at
      stub_publishing_api_has_item(
        default_publishing_api_item(withdrawn_edition,
                                    publication_state: "unpublished",
                                    public_updated_at: first_published_at,
                                    unpublishing: {
                                      type: "withdrawal",
                                      unpublished_at: withdrawal.withdrawn_at,
                                      explanation: html_explanation,
                                    },
                                    details: {
                                      first_public_at: first_published_at,
                                      change_history: [
                                        {
                                          note: "First published.",
                                          public_timestamp: Date.yesterday.noon,
                                        },
                                      ],
                                    }),
      )

      stub_publishing_api_has_links(
        content_id: withdrawn_edition.content_id, links: {},
      )

      integrity_check = described_class.new(withdrawn_edition)
      expect(integrity_check.valid?).to be true
    end

    context "when removed content" do
      let(:removal) do
        build(:removal,
              explanatory_note: markdown_explanation,
              alternative_url: "/somewhere")
      end

      let(:removed_edition) do
        build(:edition,
              :removed,
              document_type: document_type,
              first_published_at: Date.yesterday.noon,
              removal: removal)
      end

      let(:first_published_at) { removed_edition.document.first_published_at }

      before do
        stub_publishing_api_has_links(
          content_id: removed_edition.content_id, links: {},
        )
      end

      it "returns true if removed data matches the Publishing API" do
        stub_publishing_api_has_item(
          default_publishing_api_item(removed_edition,
                                      publication_state: "unpublished",
                                      public_updated_at: first_published_at,
                                      unpublishing: {
                                        type: "gone",
                                        explanation: html_explanation,
                                        alternative_path: "/somewhere",
                                      },
                                      details: {
                                        first_public_at: first_published_at,
                                        change_history: [
                                          {
                                            note: "First published.",
                                            public_timestamp: first_published_at,
                                          },
                                        ],
                                      }),
        )

        integrity_check = described_class.new(removed_edition)
        expect(integrity_check.valid?).to be true
      end

      it "returns true if there is an unpublished time mismatch" do
        stub_publishing_api_has_item(
          default_publishing_api_item(removed_edition,
                                      publication_state: "unpublished",
                                      public_updated_at: first_published_at,
                                      unpublishing: {
                                        type: "gone",
                                        unpublished_at: Date.yesterday.end_of_day,
                                        explanation: html_explanation,
                                        alternative_path: "/somewhere",
                                      },
                                      details: {
                                        first_public_at: first_published_at,
                                        change_history: [
                                          {
                                            note: "First published.",
                                            public_timestamp: first_published_at,
                                          },
                                        ],
                                      }),
        )

        integrity_check = described_class.new(removed_edition)
        expect(integrity_check.valid?).to be true
      end
    end

    context "with an attachment not yet on asset mananger" do
      let(:file_attachment_revision) { create(:file_attachment_revision) }
      let(:edition) do
        build(:edition,
              document: create(:document, first_published_at: "2020-03-11 12:00:00 +0000"),
              document_type: document_type,
              file_attachment_revisions: [file_attachment_revision],
              contents: {
                body: "[InlineAttachment:#{file_attachment_revision.filename}]",
              })
      end

      let(:publishing_api_item) do
        default_publishing_api_item(edition,
                                    publication_state: "draft",
                                    details: {
                                      body: GovspeakDocument.new(edition.contents["body"], edition).payload_html,
                                      first_public_at: "2020-03-11T12:00:00.000+00:00",
                                    })
      end

      it "returns true if there aren't any problems" do
        stub_publishing_api_has_links(content_id: edition.content_id)
        publishing_api_item[:details] = publishing_api_item[:details].except(:change_history)
        stub_publishing_api_has_item(publishing_api_item)

        expect(integrity_check.valid?).to be true
      end
    end
  end

  describe "#problems" do
    let(:edition) do
      build(:edition,
            :published,
            document_type: document_type,
            image_revisions: [build(:image_revision)],
            document: create(:document, first_published_at: "2020-03-11 18:32:38 UTC"),
            tags: { "organisations" => [] })
    end

    let(:publishing_api_item) do
      {
        content_id: edition.content_id,
        base_path: "base-path",
        title: "title",
        description: "description",
        document_type: "news_story",
        schema_name: "news_article",
        state_history: { "1" => "published" },
        details: {
          body: "body text",
          change_history: [
            {
              note: "",
              public_timestamp: Time.zone.now,
            },
          ],
          image: {
            alt_text: "alt text",
            caption: "caption",
          },
        },
        links: {
          primary_publishing_organisation: [SecureRandom.uuid],
          organisations: [SecureRandom.uuid],
        },
      }
    end

    let(:integrity_check) { described_class.new(edition) }

    def problem_description(message, expected, actual)
      "#{message}, expected: #{expected.inspect}, actual: #{actual.inspect}"
    end

    before do
      stub_publishing_api_has_links(content_id: edition.content_id)
      stub_publishing_api_has_item(publishing_api_item)
    end

    it "returns a problem when states are not equivalent" do
      publishing_api_item[:publication_state] = "draft"

      stub_publishing_api_has_item(publishing_api_item)
      expect(integrity_check.problems).to include(
        problem_description("publication_state isn't as expected",
                            publishing_api_item[:publication_state],
                            edition.state),
      )
    end

    it "returns a problem when first_published_at times don't match" do
      publishing_api_item[:details][:first_public_at] = "2020-03-11T12:00:00.000+00:00"
      stub_publishing_api_has_item(publishing_api_item)

      expect(integrity_check.problems).to include(
        problem_description("our first_published_at doesn't match first_public_at",
                            publishing_api_item[:details][:first_public_at],
                            edition.document.first_published_at.as_json),
      )
    end

    it "returns a problem when public_updated_at times don't match" do
      publishing_api_item[:public_updated_at] = "2020-03-11T12:00:00Z"
      stub_publishing_api_has_item(publishing_api_item)

      expect(integrity_check.problems).to include(
        problem_description("public_updated_at doesn't match",
                            publishing_api_item[:public_updated_at],
                            edition.public_first_published_at.as_json),
      )
    end

    it "returns a problem when the base paths don't match" do
      expect(integrity_check.problems).to include(
        problem_description("base_path doesn't match",
                            publishing_api_item[:base_path],
                            edition.base_path),
      )
    end

    it "returns a problem when the titles don't match" do
      expect(integrity_check.problems).to include(
        problem_description("title doesn't match",
                            publishing_api_item[:title],
                            edition.title),
      )
    end

    it "returns a problem when the descriptions don't match" do
      expect(integrity_check.problems).to include(
        problem_description("description doesn't match",
                            publishing_api_item[:description],
                            edition.summary),
      )
    end

    it "returns a problem when the document types don't match" do
      expect(integrity_check.problems).to include(
        problem_description("document_type doesn't match",
                            publishing_api_item[:document_type],
                            edition.document_type.id),
      )
    end

    it "returns a problem when the schema names don't match" do
      edition_schema_name = edition.document_type.publishing_metadata.schema_name
      expect(integrity_check.problems).to include(
        problem_description("schema_name doesn't match",
                            publishing_api_item[:schema_name],
                            edition_schema_name),
      )
    end

    it "returns a problem when the body text doesn't match" do
      expect(integrity_check.problems).to include("body text doesn't match")
    end

    it "returns a problem when the change history doesn't match" do
      expect(integrity_check.problems).to include("change history doesn't match")
    end

    it "returns a problem when the image alt_text doesn't match" do
      edition_image = edition.image_revisions.first
      publishing_api_image = publishing_api_item[:details][:image]

      expect(integrity_check.problems).to include(
        problem_description("image alt_text doesn't match",
                            publishing_api_image[:alt_text],
                            edition_image.alt_text),
      )
    end

    it "returns a problem when the image caption doesn't match" do
      edition_image = edition.image_revisions.first
      publishing_api_image = publishing_api_item[:details][:image]

      expect(integrity_check.problems).to include(
        problem_description("image caption doesn't match",
                            publishing_api_image[:caption],
                            edition_image.caption),
      )
    end

    it "returns a problem when the primary_publishing_organisation doesn't match" do
      expect(integrity_check.problems).to include(
        problem_description("primary_publishing_organisation doesn't match",
                            publishing_api_item[:links][:primary_publishing_organisation],
                            edition.tags["primary_publishing_organisation"]),
      )
    end

    it "returns a problem when the organisations don't match" do
      expected = publishing_api_item[:links][:organisations].inspect
      actual = edition.tags["organisations"].inspect
      message = "organisations don't match, expected: #{expected}, actual: #{actual}"

      expect(integrity_check.problems).to include(message)
    end

    context "when the edition is withdrawn" do
      let(:edition) do
        build(:edition,
              :withdrawn,
              first_published_at: Date.yesterday.noon,
              withdrawal: build(:withdrawal))
      end

      let(:integrity_check) { described_class.new(edition) }
      let(:unpublishing_explanation) { "This has been moved elsewhere" }
      let(:publishing_api_item) do
        default_publishing_api_item(edition,
                                    publication_state: "unpublished",
                                    public_updated_at: Date.yesterday.noon,
                                    unpublishing: {
                                      type: "gone",
                                      unpublished_at: Date.yesterday.end_of_day.rfc3339,
                                      explanation: unpublishing_explanation,
                                    },
                                    details: {
                                      first_public_at: Date.yesterday.noon,
                                    })
      end

      before do
        stub_publishing_api_has_item(publishing_api_item)
      end

      it "returns a problem when publishing api's unpublishing is missing" do
        publishing_api_item = default_publishing_api_item(edition,
                                                          publication_state: "published")
        stub_publishing_api_has_item(publishing_api_item)
        integrity_check = described_class.new(edition)

        expect(integrity_check.problems).to include(
          "publishing api's unpublishing is missing",
        )
      end

      it "returns a problem when the unpublishing type isn't correct" do
        expect(integrity_check.problems).to include(
          problem_description("unpublishing type not expected",
                              "withdrawal",
                              publishing_api_item[:unpublishing][:type]),
        )
      end

      it "returns a problem when the unpublishing time isn't correct" do
        expect(integrity_check.problems).to include(
          problem_description("unpublishing time doesn't match",
                              publishing_api_item[:unpublishing][:unpublished_at],
                              edition.status.details.withdrawn_at),
        )
      end

      it "returns a problem when the unpublishing explanation isn't correct" do
        expect(integrity_check.problems).to include(
          "unpublishing explanation doesn't match",
        )
      end
    end

    context "when the edition is removed" do
      let(:removal) { build(:removal) }
      let(:edition) { build(:edition, :removed, removal: removal) }
      let(:unpublishing_explanation) { "This was removed" }
      let(:integrity_check) { described_class.new(edition) }
      let(:publishing_api_item) do
        default_publishing_api_item(edition,
                                    publication_state: "unpublished",
                                    unpublishing: {
                                      type: "withdrawn",
                                      explanation: unpublishing_explanation,
                                    })
      end

      before do
        stub_publishing_api_has_item(publishing_api_item)
      end

      it "returns a problem when the unpublishing type isn't correct" do
        expect(integrity_check.problems).to include(
          problem_description("unpublishing type not expected",
                              "gone",
                              publishing_api_item[:unpublishing][:type]),
        )
      end

      it "returns a problem when the unpublishing explanation isn't correct" do
        expect(integrity_check.problems).to include(
          "unpublishing explanation doesn't match",
        )
      end
    end

    context "when the edition is removed and redirected" do
      let(:removal) { build(:removal, redirect: true, alternative_url: "/somewhere") }
      let(:edition) { build(:edition, :removed, removal: removal) }
      let(:publishing_api_item) do
        default_publishing_api_item(edition,
                                    publication_state: "unpublished",
                                    unpublishing: {
                                      type: "withdrawn",
                                      alternative_path: "/somewhere-else",
                                    })
      end

      before do
        stub_publishing_api_has_item(publishing_api_item)
      end

      it "returns a problem when the unpublishing type isn't correct" do
        integrity_check = described_class.new(edition)

        expect(integrity_check.problems).to include(
          problem_description("unpublishing type not expected",
                              "redirect",
                              publishing_api_item[:unpublishing][:type]),
        )
      end

      it "returns a problem when the alternative path doesn't match" do
        expect(integrity_check.problems).to include(
          problem_description("unpublishing alternative path doesn't match",
                              publishing_api_item[:unpublishing][:alternative_path],
                              edition.status.details.alternative_url),
        )
      end
    end
  end

  describe ".time_matches?" do
    let(:time) { Time.zone.now }

    it "returns true when times match" do
      expect(described_class.time_matches?(time.rfc3339, time.rfc3339)).to eq true
    end

    it "returns true when times are sufficiently similar" do
      expect(described_class.time_matches?((time + 4).rfc3339, time.rfc3339)).to eq true
    end

    it "returns false when times are not sufficiently similar" do
      expect(described_class.time_matches?((time + 30).rfc3339, time.rfc3339)).to eq false
    end

    it "returns false when times are invalid" do
      expect(described_class.time_matches?("Not a time", nil)).to eq false
    end
  end

  def default_publishing_api_item(edition, override_hash = {})
    {
      content_id: edition.content_id,
      base_path: edition.base_path,
      title: edition.title,
      description: edition.summary,
      document_type: edition.document_type.id,
      schema_name: edition.document_type.publishing_metadata.schema_name,
      details: {
        body: "",
        change_history: [
          {
            note: "First published.",
            public_timestamp: Time.zone.rfc3339("2020-03-11T12:00:45.000+00:00"),
          },
        ],
      },
    }.deep_merge!(override_hash)
  end
end
