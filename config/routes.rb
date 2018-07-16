# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/content')
  get '/dev' => 'development#index'

  get '/content' => 'content#index'
  get '/content/new' => 'content#choose_format', as: :new_document
  post '/content/create' => 'content#create', as: :create_content
  get '/content/:id/edit' => 'content#edit', as: :edit_document
  patch '/content/:id' => 'content#update', as: :document

  get "/healthcheck", to: proc { [200, {}, ["OK"]] }
end
