class AccessLimitController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "edit_api_down", status: :service_unavailable
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
  end

  def update
    result = AccessLimit::UpdateInteractor.call(params:, user: current_user)
    @edition, issues = result.to_h.values_at(:edition, :issues)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :edit,
             assigns: { issues: },
             status: :unprocessable_entity
    else
      redirect_to document_path(@edition.document)
    end
  end
end
