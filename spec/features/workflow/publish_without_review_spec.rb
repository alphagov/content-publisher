# frozen_string_literal: true

RSpec.feature "Publish without review" do
  include ActiveSupport::Testing::TimeHelpers

  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_publish_without_review
    then_i_see_the_publish_succeeded
    and_the_editors_receive_an_email

    when_i_visit_the_summary_page
    then_i_see_it_has_not_been_reviewed

    when_i_click_the_approve_button
    then_i_see_that_its_reviewed
  end

  def given_there_is_an_edition
    @creator = create(:user, email: "someone@example.com")

    @edition = create(:edition, :publishable,
                      created_by: @creator,
                      created_at: 1.day.ago,
                      base_path: "/news/banana-pricing-updates")
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def when_i_click_the_approve_button
    travel_to(@publish_date + 1.hour) do
      click_on "Approve"
    end
  end

  def and_i_publish_without_review
    travel_to(@publish_date = Time.current) do
      click_on "Publish"
      choose I18n.t!("publish.confirmation.should_be_reviewed")
      stub_any_publishing_api_publish
      click_on "Confirm publish"
    end
  end

  def then_i_see_the_publish_succeeded
    expect(page).to have_content(I18n.t!("publish.published.published_without_review.title"))
  end

  def then_i_see_it_has_not_been_reviewed
    expect(page).to have_content I18n.t!("user_facing_states.published_but_needs_2i.name")

    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.published_without_review")
    end
  end

  def then_i_see_that_its_reviewed
    expect(page).to have_content I18n.t!("documents.show.flashes.approved")
    expect(page).to have_content I18n.t!("user_facing_states.published.name")

    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.approved")
    end
  end

  def and_the_editors_receive_an_email
    tos = ActionMailer::Base.deliveries.map(&:to)
    message = ActionMailer::Base.deliveries.first

    publish_time = @publish_date.strftime("%l:%M%P").strip
    publish_date = @publish_date.strftime("%d %B %Y")
    publish_user = current_user.name

    expect(tos).to match_array [[@creator.email], [current_user.email]]
    expect(message.body).to include("https://www.test.gov.uk/news/banana-pricing-updates")
    expect(message.body).to include(document_path(@edition.document))

    expect(message.subject).to eq(I18n.t("publish_mailer.publish_email.subject.published_but_needs_2i",
                                         title: @edition.title))

    expect(message.body).to include(I18n.t("publish_mailer.publish_email.details.publish",
                                           time: publish_time,
                                           date: publish_date,
                                           user: publish_user))
  end
end
