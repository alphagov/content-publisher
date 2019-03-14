# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect("/documents")

  get "/documents/publishing-guidance" => "new_document#guidance", as: :guidance
  get "/documents/new" => "new_document#choose_supertype", as: :new_document
  get "/documents/choose-document-type" => "new_document#choose_document_type", as: :choose_document_type
  post "/documents/create" => "new_document#create", as: :create_document

  get "/documents/:document/publish" => "publish#confirmation", as: :publish_confirmation
  post "/documents/:document/publish" => "publish#publish"
  get "/documents/:document/published" => "publish#published", as: :published

  post "/documents/:document/save-scheduled-publishing-datetime" => "schedule#save_scheduled_publishing_datetime", as: :save_scheduled_publishing_datetime
  post "/documents/:document/clear-scheduled-publishing-datetime" => "schedule#clear_scheduled_publishing_datetime", as: :clear_scheduled_publishing_datetime

  get "/documents/:document/schedule" => "schedule#confirmation", as: :scheduling_confirmation
  post "/documents/:document/schedule" => "schedule#schedule"
  get "/documents/:document/scheduled" => "schedule#scheduled", as: :scheduled

  post "/documents/:id/unschedule" => "unschedule#unschedule", as: :unschedule

  get "/documents" => "documents#index"
  get "/documents/:document/edit" => "documents#edit", as: :edit_document
  patch "/documents/:document" => "documents#update", as: :document
  get "/documents/:document" => "documents#show"
  get "/documents/:document/generate-path" => "documents#generate_path", as: :generate_path
  get "/documents/:document/delete-draft" => "documents#confirm_delete_draft", as: :delete_draft
  delete "/documents/:document" => "documents#destroy"

  post "/documents/:document/internal_notes" => "internal_notes#create", as: :create_internal_note

  get "/documents/:document/debug" => "debug#index", as: :debug_document

  get "/documents/:document/search-contacts" => "contacts#search", as: :search_contacts
  post "/documents/:document/search-contacts" => "contacts#insert", as: :insert_contact

  post "/documents/:document/submit-for-2i" => "review#submit_for_2i", as: :submit_document_for_2i
  post "/documents/:document/approve" => "review#approve", as: :approve_document

  get "/documents/:document/tags" => "tags#edit", as: :tags
  post "/documents/:document/tags" => "tags#update"

  get "/documents/:document/preview" => "preview#show", as: :preview_document
  post "/documents/:document/create-preview" => "preview#create", as: :create_preview

  get "/documents/:document/withdraw" => "withdraw#new", as: :withdraw
  post "/documents/:document/withdraw" => "withdraw#create"

  get "/documents/:document/unwithdraw" => "unwithdraw#confirm", as: :confirm_unwithdraw
  post "/documents/:document/unwithdraw" => "unwithdraw#unwithdraw", as: :unwithdraw

  get "/documents/:document/remove" => "unpublish#remove", as: :remove

  get "/documents/:document/images" => "images#index", as: :images
  post "/documents/:document/images" => "images#create", as: :create_image
  get "/documents/:document/images/:image_id/download" => "images#download", as: :download_image
  get "/documents/:document/images/:image_id/crop" => "images#crop", as: :crop_image
  patch "/documents/:document/images/:image_id/crop" => "images#update_crop"
  get "/documents/:document/images/:image_id/edit" => "images#edit", as: :edit_image
  patch "/documents/:document/images/:image_id/edit" => "images#update", as: :update_image
  delete "/documents/:document/images/:image_id" => "images#destroy", as: :destroy_image

  post "/documents/:document/lead-image/:image_id" => "lead_image#choose", as: :choose_lead_image
  delete "/documents/:document/lead-image" => "lead_image#remove", as: :remove_lead_image

  get "/documents/:document/topics" => "topics#edit", as: :topics
  patch "/documents/:document/topics" => "topics#update", as: :update_topics

  post "/documents/:document/editions" => "editions#create", as: :create_edition

  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  get "/documentation" => "documentation#index"

  get "/how-to-use-publisher" => "publisher_information#how_to_use_publisher", as: :how_to_use_publisher
  get "/beta-capabilities" => "publisher_information#beta_capabilities", as: :beta_capabilities
  get "/publisher-updates" => "publisher_information#publisher_updates", as: :publisher_updates

  post "/documents/:document/govspeak-preview" => "govspeak_preview#to_html", as: :govspeak_preview

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  if Rails.env.test?
    get "/government/*all", to: proc { [200, {}, ["You've been redirected"]] }
  end
end
