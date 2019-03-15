# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect("/documents")

  get "/documents/publishing-guidance" => "new_document#guidance", as: :guidance
  get "/documents/new" => "new_document#choose_supertype", as: :new_document
  get "/documents/choose-document-type" => "new_document#choose_document_type", as: :choose_document_type
  post "/documents/create" => "new_document#create", as: :create_document

  get "/documents" => "documents#index"

  scope "/documents/:document" do
    get "" => "documents#show", as: :document
    patch "" => "documents#update"
    delete "" => "documents#destroy"
    get "/edit" => "documents#edit", as: :edit_document
    get "/generate-path" => "documents#generate_path", as: :generate_path
    get "/delete-draft" => "documents#confirm_delete_draft", as: :delete_draft

    get "/publish" => "publish#confirmation", as: :publish_confirmation
    post "/publish" => "publish#publish"
    get "/published" => "publish#published", as: :published

    post "/save-scheduled-publishing-datetime" => "schedule#save_scheduled_publishing_datetime", as: :save_scheduled_publishing_datetime
    post "/clear-scheduled-publishing-datetime" => "schedule#clear_scheduled_publishing_datetime", as: :clear_scheduled_publishing_datetime

    get "/schedule" => "schedule#confirmation", as: :scheduling_confirmation
    post "/schedule" => "schedule#schedule"
    get "/scheduled" => "schedule#scheduled", as: :scheduled

    post "/unschedule" => "unschedule#unschedule", as: :unschedule

    post "/internal_notes" => "internal_notes#create", as: :create_internal_note

    get "/debug" => "debug#index", as: :debug_document

    get "/search-contacts" => "contacts#search", as: :search_contacts
    post "/search-contacts" => "contacts#insert", as: :insert_contact

    post "/submit-for-2i" => "review#submit_for_2i", as: :submit_document_for_2i
    post "/approve" => "review#approve", as: :approve_document

    get "/tags" => "tags#edit", as: :tags
    post "/tags" => "tags#update"

    get "/preview" => "preview#show", as: :preview_document
    post "/create-preview" => "preview#create", as: :create_preview

    get "/withdraw" => "withdraw#new", as: :withdraw
    post "/withdraw" => "withdraw#create"

    get "/unwithdraw" => "unwithdraw#confirm", as: :confirm_unwithdraw
    post "/unwithdraw" => "unwithdraw#unwithdraw", as: :unwithdraw

    get "/remove" => "unpublish#remove", as: :remove

    get "/images" => "images#index", as: :images
    post "/images" => "images#create", as: :create_image
    get "/images/:image_id/download" => "images#download", as: :download_image
    get "/images/:image_id/crop" => "images#crop", as: :crop_image
    patch "/images/:image_id/crop" => "images#update_crop"
    get "/images/:image_id/edit" => "images#edit", as: :edit_image
    patch "/images/:image_id/edit" => "images#update", as: :update_image
    delete "/images/:image_id" => "images#destroy", as: :destroy_image

    post "/lead-image/:image_id" => "lead_image#choose", as: :choose_lead_image
    delete "/lead-image" => "lead_image#remove", as: :remove_lead_image

    get "/topics" => "topics#edit", as: :topics
    patch "/topics" => "topics#update", as: :update_topics

    post "/editions" => "editions#create", as: :create_edition

    post "/govspeak-preview" => "govspeak_preview#to_html", as: :govspeak_preview
  end

  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  get "/documentation" => "documentation#index"

  get "/how-to-use-publisher" => "publisher_information#how_to_use_publisher", as: :how_to_use_publisher
  get "/beta-capabilities" => "publisher_information#beta_capabilities", as: :beta_capabilities
  get "/publisher-updates" => "publisher_information#publisher_updates", as: :publisher_updates

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  if Rails.env.test?
    get "/government/*all", to: proc { [200, {}, ["You've been redirected"]] }
  end
end
