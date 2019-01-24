# frozen_string_literal: true

module TopicsHelper
  ENDPOINT = GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT

  def stub_any_publishing_api_no_links
    stub_request(:get, %r(\A#{ENDPOINT}/links/[a-z0-9\-]+\Z))
      .to_return(status: 200, body: { "links": {} }.to_json)
  end

  def stub_publishing_api_has_taxonomy
    # GOV.UK homepage
    stub_publishing_api_has_expanded_links(
      "content_id" => "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a",
      "expanded_links" => {
        "level_one_taxons" => [
          {
            "title" => "Level One Topic",
            "content_id" => "level_one_topic",
          },
        ],
      },
    )

    stub_publishing_api_has_expanded_links(
      "content_id" => "level_one_topic",
      "expanded_links" => {
        "legacy_taxons" => [
          {
            "content_id" => "specialist_sector_1",
            "document_type" => "topic",
          },
          {
            "content_id" => "another_legacy_taxon",
          },
        ],
        "child_taxons" => [
          {
            "content_id" => "level_two_topic",
            "title" => "Level Two Topic",
            "links" => {
              "child_taxons" => [
                {
                  "content_id" => "level_three_topic",
                  "title" => "Level Three Topic",
                  "links" => {},
                },
              ],
              "legacy_taxons" => [
                {
                  "content_id" => "specialist_sector_2",
                  "document_type" => "topic",
                },
              ],
            },
          },
        ],
      },
    )
  end
end
