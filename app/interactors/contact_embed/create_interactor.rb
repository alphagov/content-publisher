class ContactEmbed::CreateInteractor < ApplicationInteractor
  delegate :params,
           :markdown_code,
           :edition,
           :issues,
           to: :context

  def call
    find_edition
    check_for_issues
    generate_markdown_code
  end

private

  def find_edition
    context.edition = Edition.find_current(document: params[:document])
  end

  def check_for_issues
    issues = Requirements::CheckerIssues.new
    issues.create(:contact_embed, :blank) if params[:contact_id].blank?
    context.fail!(issues: issues) if issues.any?
  end

  def generate_markdown_code
    context.markdown_code = I18n.t!(
      "contact_embed.new.contact_markdown",
      id: params[:contact_id],
    )
  end
end
