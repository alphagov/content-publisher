# frozen_string_literal: true

RSpec.describe "tags/edit.html.erb" do
  it "shows a warning when editing the primary organisation tag of an access limited edition" do
    tag_field = build(:tag_field, :primary_publishing_organisation)
    document_type = build(:document_type, tags: [tag_field])
    edition = build(:edition,
                    :access_limited,
                    document_type_id: document_type.id,
                    created_by: current_user)
    stub_publishing_api_has_linkables(
      [{ "content_id" => current_user.organisation_content_id,
         "internal_name" => "Organisation" }],
      document_type: tag_field.document_type,
    )

    assign(:edition, edition)
    assign(:revision, edition.revision)
    render

    expect(rendered)
      .to have_content(I18n.t!("tags.edit.organisation_warning"))
  end
end
