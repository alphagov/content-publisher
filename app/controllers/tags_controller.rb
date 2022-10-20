class TagsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
  end

  def update
    results = Tags::UpdateInteractor.call(params:, user: current_user)
    edition, issues, = results.to_h.values_at(:edition, :issues)

    if issues
      flash.now["requirements"] = {
        "items" => issues.items(link_options: issues_link_options(edition)),
      }
      render :edit,
             assigns: { edition:, issues: },
             status: :unprocessable_entity
    else
      redirect_to document_path(params[:document])
    end
  end

private

  def issues_link_options(edition)
    edition.document_type.tags.each_with_object({}) do |field, memo|
      memo[field.id.to_sym] = { href: "##{field.id}-field" }
    end
  end
end
