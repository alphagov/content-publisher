# frozen_string_literal: true

RSpec.feature "Drafting requirements" do
  include TopicsHelper

  scenario do
    given_there_is_a_document
    when_the_document_has_issues_to_fix
    then_i_see_a_warning_to_fix_the_issues

    #when_i_try_to_generate_a_preview
    #then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_a_document
    document_type_schema = build(:document_type_schema, lead_image: true)
    @document = create(:document, document_type: document_type_schema.id)
  end

  def when_the_document_has_issues_to_fix
    @image = create(:image, document: @document)
    visit document_path(@document)
  end

  def then_i_see_a_warning_to_fix_the_issues
    within(".app-c-notice") do
      expect(page).to have_content(I18n.t!("requirements.alt_text.blank.summary_message", filename: @image.filename))
    end
  end
end
