# frozen_string_literal: true

RSpec.feature "Access internal notes without the pre-release features permission" do
  scenario do
    given_there_is_a_document
    and_i_dont_have_pre_release_features_permission
    when_i_visit_the_document_page
    then_i_cant_see_the_input_box_for_internal_notes
  end

  def given_there_is_a_document
    create(:document, :with_current_edition)
  end

  def and_i_dont_have_pre_release_features_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions - [User::PRE_RELEASE_FEATURES_PERMISSION])
  end

  def when_i_visit_the_document_page
    visit document_path(Document.last)
  end

  def then_i_cant_see_the_input_box_for_internal_notes
    expect(page).to have_no_css("textarea[name='internal_note']")
  end
end
