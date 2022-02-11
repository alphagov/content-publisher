class CollectionItemsController < ApplicationController
  before_action :fetch_collection, only: %w[index new edit confirm_delete reorder]

  def create
    result = CollectionItems::CreateInteractor.call(params: params, user: current_user)
    edition, collection, issues, = result.to_h.values_at(:edition, :collection, :issues)

    if issues
      render :new,
             assigns: { issues: issues },
             status: :unprocessable_entity
    else
      redirect_to collection_items_path(edition.document, collection.id)
    end
  end

  def edit
    @item = @edition.contents[@collection.id].to_a.find { |item| item["id"] == params[:item_id] }
    raise ActionController::RoutingError, "Item #{params[:item_id]} not found" unless @item
  end

  def update
    result = CollectionItems::UpdateInteractor.call(params: params, user: current_user)
    edition, collection, issues, = result.to_h.values_at(:edition, :collection, :issues)

    if issues
      render :new,
             assigns: { issues: issues },
             status: :unprocessable_entity
    else
      redirect_to collection_items_path(edition.document, collection.id)
    end
  end

  def confirm_delete
    @item = @edition.contents[@collection.id].to_a.find { |item| item["id"] == params[:item_id] }
    raise ActionController::RoutingError, "Item #{params[:item_id]} not found" unless @item
  end

  def destroy
    result = CollectionItems::DestroyInteractor.call(params: params, user: current_user)
    collection = result.collection

    redirect_to collection_items_path(params[:document], params[:collection_id]),
                notice: "#{collection.singular_name.capitalize} deleted"
  end

  def update_order
    result = CollectionItems::UpdateOrderInteractor.call(params: params, user: current_user)
    edition, collection = result.to_h.values_at(:edition, :collection)
    redirect_to collection_items_path(edition.document, collection.id)
  end

private

  def fetch_collection
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    @collection = @edition.document_type.collections[params[:collection_id]]

    assert_edition_feature(@edition, assertion: "supports requested collection") do
      @collection.present?
    end
  end
end
