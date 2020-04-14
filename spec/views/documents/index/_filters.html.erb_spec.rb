RSpec.describe "documents/index/_filters" do
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
        render
        expect(rendered).to have_select("organisation",
                                        options: ["", "Org 1", "Org 2"])
      end
    end

    context "when organisations fail to load from the Publishing API" do
      it "renders an empty option in the organisation filter" do
        stub_publishing_api_isnt_available
        render
        expect(rendered).to have_select("organisation", options: [""])
      end
    end
  end

  describe "Document type select" do
    let(:pre_release_document_type) { build(:document_type, :pre_release) }

    before do
      stub_publishing_api_has_linkables([], document_type: "organisation")

      allow(DocumentType)
        .to receive(:all)
        .and_return([pre_release_document_type])
    end

    it "includes pre-release document types when the user has pre_release_features permissions" do
      render
      expect(rendered).to include(pre_release_document_type.label)
    end

    it "excludes pre-release document types when the user does not have pre_release_features permissions" do
      user = build(:user, permissions: %w(signin))
      login_as(user)

      render
      expect(rendered).not_to include(pre_release_document_type.label)
    end
  end
end
