Rails.application.routes.draw do
  # Search ---------------------------------------------------------------------
  resource :search, only: :create
  namespace :companies do
    resource :search, only: [:create, :show]
  end

  # Main Resources -------------------------------------------------------------
  resource :user, only: [:show, :update]
  resources :companies, except: [:index, :new, :edit] do
    resources :commitments, only: [:create, :update, :destroy], shallow: true
    resources :supply_links, only: [:destroy], shallow: true
    resources :purchasers, only: [:create, :update],
                           controller: 'supply_links/purchasers'
    resources :suppliers, only: [:create, :update],
                          controller: 'supply_links/suppliers'
    namespace :items do
      resource :search, only: [:create]
    end
    resources :items, only: [:create, :update, :destroy]
  end

  resources :orders do
    resources :line_items, only: [:create, :update, :destroy]
  end

  resources :supply_links, only: [], shallow: true do
    resource :report, only: [:new, :show]
  end

  # Authentication -------------------------------------------------------------
  # See https://github.com/plataformatec/devise#configuring-routes
  devise_for :accounts, path: '', skip: [:registrations]

  devise_scope :account do
    get    '/join',    to: 'devise/registrations#new',     as: :new_account_registration
    post   '/account', to: 'devise/registrations#create',  as: :account_registration
    patch  '/account', to: 'devise/registrations#update',  as: ''
    put    '/account', to: 'devise/registrations#update',  as: ''
    delete '/account', to: 'devise/registrations#destroy', as: ''
  end

  get '/account', to: redirect('/join')

  # Static pages ---------------------------------------------------------------
  root 'dashboards#show'

  HighVoltage.configure do |config|
    config.route_drawer = HighVoltage::RouteDrawers::Root
  end
end
