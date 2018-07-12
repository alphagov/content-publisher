# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'development#index'

  get "/healthcheck", to: proc { [200, {}, ["OK"]] }

  root 'tmp#index'

  resources :tmp, only: [:index]
end
