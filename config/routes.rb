# frozen_string_literal: true

ActiveQuery::GUI::Engine.routes.draw do
  resources :queries, only: [:index] do
    post :execute, on: :collection
  end

  root to: "queries#index"
end
