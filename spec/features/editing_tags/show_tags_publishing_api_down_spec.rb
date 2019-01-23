# frozen_string_literal: true

RSpec.feature "Showing tags when the Publishing API is down" do
  scenario do
    given_there_is_an_edition_with_tags
    and_the_publishing_api_is_down
    when_i_visit_the_summary_page
    then_i_should_see_an_error_message
  end

  def given_there_is_an_edition_with_tags
    tag_field = build(:tag_field, type: "multi_tag")
    document_type = build(:document_type, tags: [tag_field])
    tags = { tag_field.id => ["a-content-id"] }
    @edition = create(:edition, document_type_id: document_type.id, tags: tags)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_should_see_an_error_message
    within("#tags") do
      expect(page).to have_content(I18n.t!("documents.show.tags.api_down"))
    end
  end
end
