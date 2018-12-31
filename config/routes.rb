# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect("/documents")

  get "/documents/publishing-guidance" => "new_document#guidance", as: :guidance
  get "/documents/new" => "new_document#choose_supertype", as: :new_document
  get "/documents/choose-document-type" => "new_document#choose_document_type", as: :choose_document_type
  post "/documents/create" => "new_document#create", as: :create_document

  get "/documents/:id/publish" => "publish#confirmation", as: :publish_confirmation
  post "/documents/:id/publish" => "publish#publish"
  get "/documents/:id/published" => "publish#published", as: :published

  get "/documents" => "documents#index"
  get "/documents/:id/edit" => "documents#edit", as: :edit_document
  get "/documents/:id/debug" => "documents#debug", as: :debug_document
  patch "/documents/:id" => "documents#update", as: :document
  get "/documents/:id" => "documents#show"
  get "/documents/:id/generate-path" => "documents#generate_path", as: :generate_path
  get "/documents/:id/delete-draft" => "documents#confirm_delete_draft", as: :delete_draft
  delete "/documents/:id" => "documents#destroy"

  get "/documents/:id/search-contacts" => "contacts#search", as: :search_contacts
  post "/documents/:id/search-contacts" => "contacts#insert", as: :insert_contact

  post "/documents/:id/submit-for-2i" => "review#submit_for_2i", as: :submit_document_for_2i
  post "/documents/:id/approve" => "review#approve", as: :approve_document

  get "/documents/:id/tags" => "tags#edit", as: :tags
  post "/documents/:id/tags" => "tags#update"

  get "/documents/:id/preview" => "preview#show", as: :preview_document
  post "/documents/:id/create-preview" => "preview#create", as: :create_preview

  get "/documents/:id/retire" => "unpublish#retire", as: :retire
  get "/documents/:id/remove" => "unpublish#remove", as: :remove

  get "/documents/:document_id/images" => "images#index", as: :images
  post "/documents/:document_id/images" => "images#create", as: :create_image
  get "/documents/:document_id/images/:image_id/download" => "images#download", as: :download_image
  get "/documents/:document_id/images/:image_id/crop" => "images#crop", as: :crop_image
  patch "/documents/:document_id/images/:image_id/crop" => "images#update_crop"
  get "/documents/:document_id/images/:image_id/edit" => "images#edit", as: :edit_image
  patch "/documents/:document_id/images/:image_id/edit" => "images#update", as: :update_image
  delete "/documents/:document_id/images/:image_id" => "images#destroy", as: :destroy_image

  post "/documents/:document_id/lead-image/:image_id" => "lead_image#choose", as: :choose_lead_image
  delete "/documents/:document_id/lead-image" => "lead_image#remove", as: :remove_lead_image

  get "/documents/:document_id/topics" => "topics#edit", as: :topics
  patch "/documents/:document_id/topics" => "topics#update", as: :update_topics

  post "/documents/:document_id/editions" => "editions#create", as: :create_edition

  namespace :versioned do
    get "/documents/new" => "new_document#choose_supertype", as: :new_document
    get "/documents/choose-document-type" => "new_document#choose_document_type", as: :choose_document_type
    post "/documents/create" => "new_document#create", as: :create_document

    # get "/documents/:id/publish" => "publish#confirmation", as: :publish_confirmation
    # post "/documents/:id/publish" => "publish#publish"
    # get "/documents/:id/published" => "publish#published", as: :published

    get "/documents" => "documents#index"
    get "/documents/:id/edit" => "documents#edit", as: :edit_document
    patch "/documents/:id" => "documents#update", as: :document
    get "/documents/:id" => "documents#show"
    get "/documents/:id/generate-path" => "documents#generate_path", as: :generate_path
    get "/documents/:id/delete-draft" => "documents#confirm_delete_draft", as: :delete_draft
    delete "/documents/:id" => "documents#destroy"

    get "/documents/:id/search-contacts" => "contacts#search", as: :search_contacts
    post "/documents/:id/search-contacts" => "contacts#insert", as: :insert_contact

    post "/documents/:id/submit-for-2i" => "review#submit_for_2i", as: :submit_document_for_2i
    post "/documents/:id/approve" => "review#approve", as: :approve_document

    get "/documents/:id/tags" => "tags#edit", as: :tags
    post "/documents/:id/tags" => "tags#update"

    # get "/documents/:id/preview" => "preview#show", as: :preview_document
    # post "/documents/:id/create-preview" => "preview#create", as: :create_preview
    #
    # get "/documents/:id/retire" => "unpublish#retire", as: :retire
    # get "/documents/:id/remove" => "unpublish#remove", as: :remove
    #
    # get "/documents/:document_id/images" => "images#index", as: :images
    # post "/documents/:document_id/images" => "images#create", as: :create_image
    # get "/documents/:document_id/images/:image_id/download" => "images#download", as: :download_image
    # get "/documents/:document_id/images/:image_id/crop" => "images#crop", as: :crop_image
    # patch "/documents/:document_id/images/:image_id/crop" => "images#update_crop"
    # get "/documents/:document_id/images/:image_id/edit" => "images#edit", as: :edit_image
    # patch "/documents/:document_id/images/:image_id/edit" => "images#update", as: :update_image
    # delete "/documents/:document_id/images/:image_id" => "images#destroy", as: :destroy_image
    #
    # post "/documents/:document_id/lead-image/:image_id" => "lead_image#choose", as: :choose_lead_image
    # delete "/documents/:document_id/lead-image" => "lead_image#remove", as: :remove_lead_image

    get "/documents/:document_id/topics" => "topics#edit", as: :topics
    patch "/documents/:document_id/topics" => "topics#update", as: :update_topics

    # post "/documents/:document_id/editions" => "editions#create", as: :create_edition
  end

  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  get "/documentation" => "documentation#index"

  get "/how-to-use-publisher" => "publisher_information#how_to_use_publisher", as: :how_to_use_publisher
  get "/beta-capabilities" => "publisher_information#beta_capabilities", as: :beta_capabilities
  get "/publisher-updates" => "publisher_information#publisher_updates", as: :publisher_updates

  post "/govspeak-preview" => "govspeak_preview#to_html"

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  if Rails.env.test?
    get "/government/*all", to: proc { [200, {}, ["You've been redirected"]] }
  end
end
