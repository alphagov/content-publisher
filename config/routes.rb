# frozen_string_literal: true

Rails.application.routes.draw do
  get "/healthcheck", to: proc { [200, {}, ["OK"]] }

  resources :tmp, only: [:index]
end
