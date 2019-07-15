# frozen_string_literal: true

RSpec.feature "Remove" do
  scenario do
    given_there_is_a_published_edition
    when_i_visit_the_summary_page
    and_i_click_to_remove_the_edition
    then_i_see_the_feature_is_not_built
  end

  def given_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_to_remove_the_edition
    click_on "Remove"
  end

  def then_i_see_the_feature_is_not_built
    expect(page).to have_content(I18n.t!("remove.remove.title"))
  end
end
