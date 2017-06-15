require 'sidekiq/web'

Rails.application.routes.draw do

  admin = lambda do |request|
    request.env['warden'].authenticate? && request.env['warden'].user.admin?
  end

  constraints admin do
    mount Sidekiq::Web => '/sidekiq'
    ActiveAdmin.routes(self)
  end

  devise_for :participants
  #, ActiveAdmin::Devise.config
  #ActiveAdmin.routes(self)
  resources :participants, only: [:show, :edit, :update, :destroy] do
    get :sync_mailchimp
    get :regen_api_key
    get :remove_image
    resources :email_preferences, only: [:edit, :update]
  end

  # ReactJS
  namespace :components do
    get "autocomplete" => "search_autocomplete#index"
    get "search" => "search#show", as: :search
  end


  # API
  namespace :api do
    resources :submissions, only: [:update]
    resources :external_graders, only: [:create, :show] do
      get :challenge_config, on: :collection
    end
    resources :opensim_gradings, only: [:create, :update, :show]
  end

  resources :landing_page, only: [:index]
  match '/landing_page/host', to: 'landing_page#host', via: :get

  resources :organizers do
    resources :challenges
    get :remove_image
  end

  resources :challenges do
    resources :dataset_files, only: [:new, :show, :index, :destroy, :new, :create]
    resources :events
    resources :submissions do
      get :grade
      get :hub
      get :execute
    end
    resources :leaderboards, only: [:index]
    get 'leaderboards/video_modal' => 'leaderboards#video_modal', as: :video_modal
    get 'leaderboards/submission_detail' => 'leaderboards#submission_detail', as: :submission_detail
    resources :topics
    get :regrade
    get :regen_api_key
    get :remove_image
    resources :votes, only: [:create]
  end
  get '/load_more_challenges', to: 'challenges#load_more', as: :load_more_challenges


  resources :topics do
    resources :comments, only: [:new, :create]
    resources :votes, only: [:create]
  end

  resources :comments, only: [] do
    resources :votes, only: [:create]
  end

  resources :articles do
    resources :article_sections
    resources :votes, only: [:create]
    get :remove_image
  end
  get '/load_more_articles', to: 'articles#load_more', as: :load_more_articles

  match '/pages/contact', to: 'pages#contact', via: :get
  match '/pages/privacy', to: 'pages#privacy', via: :get
  match '/pages/terms',   to: 'pages#terms', via: :get

  resources :markdown_editor, only: [:show] do
    put :presign, on: :collection
  end

  root 'landing_page#index'
end
