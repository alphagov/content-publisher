# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/documents')
  get '/dev' => 'development#index'

  get '/documents' => 'documents#index'
  get '/documents/new' => 'documents#choose_format', as: :new_document
  post '/documents/create' => 'documents#create', as: :create_document
  get '/documents/:id/edit' => 'documents#edit', as: :edit_document
  patch '/documents/:id' => 'documents#update', as: :document

  get "/healthcheck", to: proc { [200, {}, ["OK"]] }
end
