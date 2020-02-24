RSpec.describe "new_document/show.html.erb" do
  let(:pre_release_option) do
    DocumentTypeSelection::Option.new(
      id: "news",
      type: "document_type",
      pre_release: true,
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

  it "shows pre_release options when the user has pre_release_features permissions" do
    assign(:document_type_selection, document_type_selection)
    render

    title = I18n.t!("document_type_selections.#{pre_release_option.id}.label")
    expect(rendered).to include(title)
  end

  it "excludes pre_release options when the user does not have pre_release_features permissions" do
    user = build(:user, permissions: %w(signin))
    login_as(user)
    assign(:document_type_selection, document_type_selection)
    render

    title = I18n.t!("document_type_selections.#{pre_release_option.id}.label")
    expect(rendered).not_to include(title)
  end
end
