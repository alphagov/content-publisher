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
  post "/documents/:id/retry-draft" => "documents#retry_draft_save", as: :retry_draft_save
  patch "/documents/:id" => "documents#update", as: :document
  get "/documents/:id" => "documents#show"
  get "/documents/:id/generate-path" => "documents#generate_path", as: :generate_path

  post "/documents/:id/submit-for-2i" => "review#submit_for_2i", as: :submit_document_for_2i
  post "/documents/:id/approve" => "review#approve", as: :approve_document

  get "/documents/:id/tags" => "document_tags#edit", as: :document_tags
  post "/documents/:id/tags" => "document_tags#update"

  get "/documents/:id/preview" => "preview#show", as: :preview_document

  post "/documents/:document_id/images" => "document_images#create", as: :create_document_image
  patch "/documents/:document_id/images/:id" => "document_images#update", as: :update_document_image

  get "/documents/:document_id/lead-image" => "document_lead_image#index", as: :document_lead_image

  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  get "/documentation" => "documentation#index"

  post "/govspeak-preview" => "govspeak_preview#to_html"

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  if Rails.env.test?
    get "/government/*all", to: proc { [200, {}, ["You've been redirected"]] }
  end
end
