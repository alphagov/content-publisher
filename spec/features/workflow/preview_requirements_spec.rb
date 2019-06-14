# frozen_string_literal: true

RSpec.feature "Preview requirements" do
  scenario do
    given_there_is_an_edition_with_issues_to_fix
    when_i_view_the_summary_page
    then_i_see_a_warning_to_fix_the_issues

    when_i_try_to_preview_the_edition
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_an_edition_with_issues_to_fix
    document_type = build(:document_type, images: true)
    @image_revision = create(:image_revision, alt_text: "")
    @edition = create(:edition,
                      :publishable,
                      document_type_id: document_type.id,
                      lead_image_revision: @image_revision,
                      revision_synced: false)
  end

  def when_i_view_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_see_a_warning_to_fix_the_issues
    within(".app-c-inset-prompt") do
      expect(page).to have_content(I18n.t!("requirements.alt_text.blank.summary_message", filename: @image_revision.filename))
    end
  end

  def when_i_try_to_preview_the_edition
    stub_any_publishing_api_put_content
    click_on "Preview"
  end

  def then_i_see_an_error_to_fix_the_issues
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.alt_text.blank.summary_message", filename: @image_revision.filename))
    end
  end
end
