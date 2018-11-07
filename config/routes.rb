# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect("/documents")

  get "/documents/publishing-guidance" => "new_document#guidance", as: :guidance
  get "/documents/new" => "new_document#choose_supertype", as: :new_document
  get "/documents/choose-document-type" => "new_document#choose_document_type", as: :choose_document_type
  post "/documents/create" => "new_document#create", as: :create_document

  get "/documents/:id/publish" => "publish_document#confirmation", as: :publish_document
  post "/documents/:id/publish" => "publish_document#publish"
  get "/documents/:id/published" => "publish_document#published", as: :document_published

  get "/documents" => "documents#index"
  get "/documents/:id/edit" => "documents#edit", as: :edit_document
  get "/documents/:id/debug" => "documents#debug", as: :debug_document
  post "/documents/:id/retry-draft" => "documents#retry_draft_save", as: :retry_draft_save
  patch "/documents/:id" => "documents#update", as: :document
  get "/documents/:id" => "documents#show"
  get "/documents/:id/generate-path" => "documents#generate_path", as: :generate_path
  get "/documents/:id/delete-draft" => "documents#confirm_delete_draft", as: :delete_draft
  delete "/documents/:id" => "documents#destroy"

  post "/documents/:id/submit-for-2i" => "review#submit_for_2i", as: :submit_document_for_2i
  post "/documents/:id/approve" => "review#approve", as: :approve_document

  get "/documents/:id/tags" => "document_tags#edit", as: :document_tags
  post "/documents/:id/tags" => "document_tags#update"

  get "/documents/:id/preview" => "preview#show", as: :preview_document

  get "/documents/:id/retire" => "retire_document#retire", as: :retire_document
  get "/documents/:id/remove" => "remove_document#remove", as: :remove_document

  get "/documents/:document_id/images" => "document_images#index", as: :document_images
  post "/documents/:document_id/images" => "document_images#create", as: :create_document_image
  get "/documents/:document_id/images/:image_id/crop" => "document_images#crop", as: :crop_document_image
  patch "/documents/:document_id/images/:image_id/crop" => "document_images#update_crop"
  get "/documents/:document_id/images/:image_id/edit" => "document_images#edit", as: :edit_document_image
  patch "/documents/:document_id/images/:image_id/edit" => "document_images#update", as: :update_document_image
  delete "/documents/:document_id/images/:image_id" => "document_images#destroy", as: :destroy_document_image

  post "/documents/:document_id/lead-image/:image_id" => "document_lead_image#choose", as: :choose_document_lead_image
  delete "/documents/:document_id/lead-image" => "document_lead_image#remove", as: :remove_document_lead_image

  get "/documents/:document_id/topics" => "document_topics#edit", as: :document_topics
  patch "/documents/:document_id/topics" => "document_topics#update", as: :update_document_topics

  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  get "/documentation" => "documentation#index"

  post "/govspeak-preview" => "govspeak_preview#to_html"

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  if Rails.env.test?
    get "/government/*all", to: proc { [200, {}, ["You've been redirected"]] }
  end
end
