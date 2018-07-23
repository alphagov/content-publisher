# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/documents')
  get '/dev' => 'development#index'

  get '/documents/publishing-guidance' => 'new_document#guidance', as: :guidance
  get '/documents/new' => 'new_document#choose_supertype', as: :new_document
  post '/documents/new' => 'new_document#choose_document_type'
  post '/documents/create' => 'new_document#create', as: :create_document

  get '/documents' => 'documents#index'
  get '/documents/:id/edit' => 'documents#edit', as: :edit_document
  patch '/documents/:id' => 'documents#update', as: :document

  get "/healthcheck", to: proc { [200, {}, ["OK"]] }

  if Rails.env.test?
    get "/government/admin/consultations/new", to: proc { [200, {}, ["You've been redirected"]] }
  end
end
