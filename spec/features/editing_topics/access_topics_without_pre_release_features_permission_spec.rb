# frozen_string_literal: true

RSpec.feature "Access topics without the pre-release features permission" do
  scenario do
    given_there_is_a_document
    and_i_dont_have_pre_release_features_permission
    when_i_visit_the_document_page
    then_i_cant_see_the_change_topics_section
    when_i_visit_the_topics_page
    then_i_see_a_no_permission_message
  end

  def given_there_is_a_document
    create :document
  end

  def and_i_dont_have_pre_release_features_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions - [User::PRE_RELEASE_FEATURES_PERMISSION])
  end

  def when_i_visit_the_document_page
    visit document_path(Document.last)
  end

  def then_i_cant_see_the_change_topics_section
    expect(page).not_to have_link("Change Topics")
  end

  def when_i_visit_the_topics_page
    visit document_topics_path(Document.last)
  end

  def then_i_see_a_no_permission_message
    expect(page).to have_content(
      "Sorry, you don't seem to have the #{User::PRE_RELEASE_FEATURES_PERMISSION} permission for this app",
    )
  end
end
