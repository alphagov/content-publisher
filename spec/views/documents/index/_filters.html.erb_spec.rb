# frozen_string_literal: true

RSpec.describe "documents/index/_filters.html.erb" do
  describe "Organisation select" do
    context "when organisations are loaded from the Publishing API" do
      it "renders the organisations in the organisation filter" do
        stub_publishing_api_has_linkables(
          [
            { "content_id" => SecureRandom.uuid, "internal_name" => "Org 1" },
            { "content_id" => SecureRandom.uuid, "internal_name" => "Org 2" },
          ],
          document_type: "organisation",
        )
        render partial: "documents/index/filters"
        expect(rendered).to have_select("organisation",
                                        options: ["", "Org 1", "Org 2"])
      end
    end

    context "when organisations fail to load from the Publishing API" do
      it "renders an empty option in the organisation filter" do
        stub_publishing_api_isnt_available
        render partial: "documents/index/filters"
        expect(rendered).to have_select("organisation", options: [""])
      end
    end
  end
end
