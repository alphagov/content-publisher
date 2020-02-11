FactoryBot.define do
  factory :whitehall_export_file_attachment, class: "Hash" do
    skip_create

    sequence(:id)
    created_at { Time.current.rfc3339 }
    updated_at { Time.current.rfc3339 }
    title { "Some random text file" }
    accessible { false }
    isbn { "" }
    unique_reference { "" }
    command_paper_number { "" }
    order_url { "" }
    price_in_pence { nil }
    attachment_data_id { 10 }
    ordering { 0 }
    hoc_paper_number { "" }
    parliamentary_session { "" }
    unnumbered_command_paper { false }
    unnumbered_hoc_paper { false }
    attachable_id { 12 }
    attachable_type { "Edition" }
    slug { nil }
    locale { nil }
    external_url { nil }
    content_id { SecureRandom.uuid }
    deleted { false }
    print_meta_data_contact_address { nil }
    web_isbn { nil }
    url { "https://asset-manager.gov.uk/blah/847150/#{filename}" }
    type { "FileAttachment" }
    attachment_data do
      {
        "id" => 1,
        "carrierwave_file" => filename,
        "content_type" => "text/plain",
        "file_size" => 1057,
        "number_of_pages" => nil,
        "created_at" => created_at,
        "updated_at" => updated_at,
        "replaced_by_id" => nil,
        "uploaded_to_asset_manager_at" => updated_at,
        "present_at_unpublish" => false,
      }
    end
    variants do
      {
        "thumbnail" => {
          "content_type" => "image/png",
          "url" => "https://asset-manager.gov.uk/blah/847150/thumb/#{filename}",
        },
      }
    end

    transient do
      fixture_file { "text-file-74bytes.txt" }
      filename { "some-txt.txt" }
    end

    initialize_with do
      attributes.stringify_keys
    end

    after(:build) do |file_attachment, evaluator|
      WebMock.stub_request(:get, file_attachment["url"]).to_return(
        status: 200,
        body: lambda { |_request|
          File.open(Rails.root.join("spec", "fixtures", "files", evaluator.fixture_file), "rb").read
        },
      )
    end
  end
end
