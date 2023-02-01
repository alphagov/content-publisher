module TopicsHelper
  ENDPOINT = GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT

  def stub_any_publishing_api_no_links
    stub_request(:get, %r{\A#{ENDPOINT}/links/[a-z0-9-]+\Z})
      .to_return(status: 200, body: { "links": {} }.to_json)
  end

  def stub_publishing_api_has_taxonomy
    # GOV.UK homepage
    stub_publishing_api_has_expanded_links(
      {
        "content_id" => "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a",
        "expanded_links" => {
          "level_one_taxons" => [
            {
              "title" => "Level One Topic",
              "content_id" => "level_one_topic",
            },
          ],
        },
      },
    )

    stub_publishing_api_has_expanded_links(
      {
        "content_id" => "level_one_topic",
        "expanded_links" => {
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
              },
            },
          ],
        },
      },
    )
  end
end
