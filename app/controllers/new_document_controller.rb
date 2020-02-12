class NewDocumentController < ApplicationController
  rescue_from DocumentTypeSelection::NotFoundError do |e|
    raise ActionController::RoutingError, e.message
  end

  def choose_document_type
    result = NewDocument::ChooseSupertypeInteractor.call(params: params, user: current_user)
    issues, @supertype = result.to_h.values_at(:issues, :supertype)

    if result.issues
      flash.now["requirements"] = { "items" => issues.items }

      render :choose_supertype,
             assigns: { issues: issues },
             status: :unprocessable_entity
    elsif @supertype.managed_elsewhere
      redirect_to @supertype.managed_elsewhere_url
    end
  end

  def create
    result = NewDocument::CreateInteractor.call(params: params, user: current_user)
    issues, supertype, document_type, document = result.to_h.values_at(:issues,
                                                                       :supertype,
                                                                       :document_type,
                                                                       :document)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :choose_document_type,
             assigns: { issues: issues, supertype: supertype },
             status: :unprocessable_entity
    elsif result.managed_elsewhere
      redirect_to document_type.managed_elsewhere_url
    else
      redirect_to content_path(document)
    end
  end

  def show
    @document_type_selection = DocumentTypeSelection.find(params[:type] || "root")
  end

  def select
    result = NewDocument::SelectInteractor.call(params: params, user: current_user)
    issues, document, document_type_selection, selected_option = result.to_h.values_at(
      :issues,
      :document,
      :document_type_selection,
      :selected_option,
    )

    if issues
      flash.now["requirements"] = { "items" => issues.items }
      render :show,
             assigns: { issues: issues, document_type_selection: document_type_selection },
             status: :unprocessable_entity
    else
      destination = if document
                      content_path(document)
                    elsif selected_option.managed_elsewhere?
                      selected_option.managed_elsewhere_url
                    else
                      show_path(type: selected_option.id)
                    end

      redirect_to destination
    end
  end
end
