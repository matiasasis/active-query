# frozen_string_literal: true

ActiveQuery::GUI::Engine.routes.draw do
  resources :queries, only: [:index]

  root to: "queries#index"
end
