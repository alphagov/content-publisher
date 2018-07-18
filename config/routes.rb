# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/documents')
  get '/dev' => 'development#index'

  get '/documents' => 'documents#index'
  get '/documents/new' => 'documents#choose_format', as: :new_document
  post '/documents/create' => 'documents#create', as: :create_document
  patch '/documents/:id' => 'documents#update'
  post '/documents/:id/publish' => 'documents#publish', as: :publish_document

  get '/documents/:id' => 'documents#summary', as: :document
  get '/documents/:id/history' => 'documents#history', as: :document_history
  get '/documents/:id/edit' => 'documents#edit', as: :edit_document

  post '/roll-back/:id' => 'documents#roll_back_to_version', as: :roll_back_to_version

  get "/healthcheck", to: proc { [200, {}, ["OK"]] }
end
