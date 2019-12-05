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

    get "/schedule-proposal" => "schedule_proposal#edit"
    post "/schedule-proposal" => "schedule_proposal#update"
    delete "/schedule-proposal" => "schedule_proposal#destroy"

    get "/schedule/new" => "schedule#new", as: :new_schedule
    post "/schedule/new" => "schedule#create", as: :create_schedule
    get "/schedule/edit" => "schedule#edit", as: :edit_schedule
    post "/schedule/edit" => "schedule#update", as: :update_schedule
    delete "/schedule" => "schedule#destroy"
    get "/scheduled" => "schedule#scheduled", as: :scheduled

    post "/internal_notes" => "internal_notes#create", as: :create_internal_note

    get "/debug" => "debug#index", as: :debug_document

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

    get "/remove" => "remove#remove", as: :remove

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

    get "/backdate" => "backdate#edit", as: :backdate
    post "/backdate" => "backdate#update"
    delete "/backdate" => "backdate#destroy"

    get "/access-limit" => "access_limit#edit", as: :access_limit
    post "/access-limit" => "access_limit#update"

    get "/political" => "political#edit", as: :political

    post "/editions" => "editions#create", as: :create_edition

    get "/contact-embed" => "contact_embed#new"
    post "/contact-embed" => "contact_embed#create"

    post "/govspeak-preview" => "govspeak_preview#to_html", as: :govspeak_preview

    get "/file-attachments" => "file_attachments#index", as: :file_attachments
    post "/file-attachments" => "file_attachments#create", as: :create_file_attachment
    get "/file-attachments/:file_attachment_id" => "file_attachments#show", as: :file_attachment
    get "/file-attachments/:file_attachment_id/preview" => "file_attachments#preview", as: :preview_file_attachment
    get "/file-attachments/:file_attachment_id/edit" => "file_attachments#edit", as: :edit_file_attachment
    patch "/file-attachments/:file_attachment_id/edit" => "file_attachments#update", as: :update_file_attachment
    delete "/file-attachments/:file_attachment_id" => "file_attachments#destroy", as: :destroy_file_attachment
  end

  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  get "/how-to-use-publisher" => "publisher_information#how_to_use_publisher", as: :how_to_use_publisher
  get "/beta-capabilities" => "publisher_information#beta_capabilities", as: :beta_capabilities
  get "/publisher-updates" => "publisher_information#publisher_updates", as: :publisher_updates

  get "/video-embed" => "video_embed#new", as: :video_embed
  post "/video-embed" => "video_embed#create", as: :create_video_embed

  scope via: :all do
    match "/400" => "errors#bad_request"
    match "/404" => "errors#not_found"
    match "/422" => "errors#unprocessable_entity"
    match "/500" => "errors#internal_server_error"
  end

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  if Rails.env.test?
    get "/government/*all", to: proc { [200, {}, ["You've been redirected"]] }
  end
end
