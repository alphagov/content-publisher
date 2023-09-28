RSpec.describe "Publication format" do
  scenario do
    when_i_have_the_create_new_document_permission
    when_i_choose_this_document_type
    and_i_fill_in_the_form_fields
    then_the_document_should_be_previewable
  end

  def when_i_have_the_create_new_document_permission
    current_user.update(permissions: [User::CREATE_NEW_DOCUMENT_PERMISSION, User::PRE_RELEASE_FEATURES_PERMISSION])
  end

  def when_i_choose_this_document_type
    visit root_path
    click_on "Create new document"
    choose I18n.t!("document_type_selections.policy.label")
    click_on "Continue"
    choose I18n.t!("document_type_selections.policy_paper.label")
    click_on "Continue"
  end

  def and_i_fill_in_the_form_fields
    base_path = "#{Edition.last.document_type.path_prefix}/a-great-title"
    stub_publishing_api_has_lookups(base_path => Document.last.content_id)
    fill_in "title", with: "A great title"
    click_on "Save"
  end

  def then_the_document_should_be_previewable
    expect(a_request(:put, /content/).with do |req|
             expect(req.body).to be_valid_against_publisher_schema("publication")
           end).to have_been_requested
  end
end
