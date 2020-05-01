RSpec.describe "new_document/show" do
  let(:pre_release_document_type) { build(:document_type, :pre_release, id: "news") }

  let(:pre_release_option) do
    DocumentTypeSelection::Option.new(
      id: pre_release_document_type.id,
      type: "document_type",
    )
  end

  let(:document_type_selection) do
    DocumentTypeSelection.new(
      id: "root",
      options: [
        pre_release_option,
      ],
    )
  end

  before do
    allow(DocumentType)
      .to receive(:all)
      .and_return([pre_release_document_type])
  end

  it "shows pre_release options when the user has pre_release_features permissions" do
    assign(:document_type_selection, document_type_selection)
    render

    title = I18n.t!("document_type_selections.#{pre_release_option.id}.label")
    expect(rendered).to include(title)
  end

  it "excludes pre_release options when the user does not have pre_release_features permissions" do
    user = build(:user, permissions: %w[signin])
    login_as(user)
    assign(:document_type_selection, document_type_selection)
    render

    title = I18n.t!("document_type_selections.#{pre_release_option.id}.label")
    expect(rendered).not_to include(title)
  end
end
