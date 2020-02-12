Rails.application.routes.draw do
  root to: redirect("/documents")

  get "/documents/publishing-guidance" => "new_document#guidance", as: :guidance
  get "/documents/show" => "new_document#show", as: :show
  post "/documents/select" => "new_document#select", as: :select

  get "/documents" => "documents#index"

  scope "/documents/:document" do
    get "" => "documents#show", as: :document
    get "/history" => "documents#history", as: :document_history
    get "/generate-path" => "documents#generate_path", as: :generate_path

    patch "/content" => "content#update", as: :content
    get "/content" => "content#edit"

    delete "/draft" => "editions#destroy_draft", as: :destroy_draft
    get "/delete-draft" => "editions#confirm_delete_draft", as: :confirm_delete_draft

    get "/publish" => "publish#confirmation", as: :publish_confirmation
    post "/publish" => "publish#publish"
    get "/published" => "publish#published", as: :published

    get "/schedule-proposal" => "schedule_proposal#edit"
    post "/schedule-proposal" => "schedule_proposal#update"
    delete "/schedule-proposal" => "schedule_proposal#destroy"

    get "/schedule/new" => "schedule#new", as: :new_schedule
    post "/schedule/new" => "schedule#create"
    get "/schedule/edit" => "schedule#edit", as: :edit_schedule
    patch "/schedule/edit" => "schedule#update"
    delete "/schedule" => "schedule#destroy"
    get "/scheduled" => "schedule#scheduled", as: :scheduled

    post "/internal-notes" => "internal_notes#create", as: :create_internal_note

    get "/debug" => "debug#index", as: :debug_document

    post "/submit-for-2i" => "review#submit_for_2i", as: :submit_for_2i
    post "/approve" => "review#approve", as: :approve

    get "/tags" => "tags#edit", as: :tags
    patch "/tags" => "tags#update"

    get "/preview" => "preview#show", as: :preview_document
    post "/preview" => "preview#create"

    get "/withdraw" => "withdraw#new", as: :withdraw
    post "/withdraw" => "withdraw#create"

    get "/unwithdraw" => "unwithdraw#confirm", as: :unwithdraw
    post "/unwithdraw" => "unwithdraw#unwithdraw"

    get "/remove" => "remove#remove", as: :remove

    get "/images" => "images#index", as: :images
    post "/images" => "images#create"
    get "/images/:image_id/download" => "images#download", as: :download_image
    get "/images/:image_id/crop" => "images#crop", as: :crop_image
    patch "/images/:image_id/crop" => "images#update_crop"
    get "/images/:image_id/edit" => "images#edit", as: :edit_image
    patch "/images/:image_id/edit" => "images#update"
    delete "/images/:image_id" => "images#destroy", as: :destroy_image

    post "/lead-image/:image_id" => "lead_image#choose", as: :choose_lead_image
    delete "/lead-image" => "lead_image#remove", as: :remove_lead_image

    get "/topics" => "topics#edit", as: :topics
    patch "/topics" => "topics#update"

    get "/backdate" => "backdate#edit", as: :backdate
    patch "/backdate" => "backdate#update"
    delete "/backdate" => "backdate#destroy"

    get "/access-limit" => "access_limit#edit", as: :access_limit
    patch "/access-limit" => "access_limit#update"

    get "/history-mode" => "history_mode#edit", as: :history_mode
    patch "/history-mode" => "history_mode#update"

    post "/editions" => "editions#create", as: :create_edition

    get "/contact-embed" => "contact_embed#new"
    post "/contact-embed" => "contact_embed#create"

    post "/govspeak-preview" => "govspeak_preview#to_html", as: :govspeak_preview

    get "/file-attachments" => "file_attachments#index", as: :file_attachments
    post "/file-attachments" => "file_attachments#create"
    get "/file-attachments/:file_attachment_id" => "file_attachments#show", as: :file_attachment
    get "/file-attachments/:file_attachment_id/preview" => "file_attachments#preview", as: :preview_file_attachment
    get "/file-attachments/:file_attachment_id/edit" => "file_attachments#edit", as: :edit_file_attachment
    patch "/file-attachments/:file_attachment_id/edit" => "file_attachments#update"
    delete "/file-attachments/:file_attachment_id" => "file_attachments#destroy"
  end

  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  get "/how-to-use-publisher" => "publisher_information#how_to_use_publisher", as: :how_to_use_publisher
  get "/beta-capabilities" => "publisher_information#beta_capabilities", as: :beta_capabilities
  get "/publisher-updates" => "publisher_information#publisher_updates", as: :publisher_updates

  get "/video-embed" => "video_embed#new", as: :video_embed
  post "/video-embed" => "video_embed#create"

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
