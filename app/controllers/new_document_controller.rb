class NewDocumentController < ApplicationController
  rescue_from DocumentTypeSelection::NotFoundError do |e|
    raise ActionController::RoutingError, e.message
  end

  def show
    @document_type_selection = DocumentTypeSelection.find(params[:type] || "root")
  end

  def select
    result = NewDocument::SelectInteractor.call(params:, user: current_user)
    issues, document, document_type_selection, selected_option = result.to_h.values_at(
      :issues,
      :document,
      :document_type_selection,
      :selected_option,
    )

    if issues
      flash.now["requirements"] = { "items" => issues.items }
      render :show,
             assigns: { issues:, document_type_selection: },
             status: :unprocessable_entity
    else
      destination = if document
                      content_path(document)
                    elsif selected_option.managed_elsewhere?
                      selected_option.managed_elsewhere_url
                    else
                      new_document_path(type: selected_option.id)
                    end

      redirect_to destination, allow_other_host: true
    end
  end
end
