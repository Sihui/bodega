Rails.application.routes.draw do
  # Main Resources -------------------------------------------------------------
  resource :user, only: [:show, :update]
  resources :companies, except: [:index, :edit] do
    resources :commitments, only: [:create, :update, :destroy], shallow: true
    resources :supply_links, only: [:update, :destroy]
    resources :purchasers, only: [:create, :update], controller: 'supply_links/purchasers'
    resources :suppliers, only: [:create, :update], controller: 'supply_links/suppliers'
    resources :items, only: [:create, :update, :destroy]
  end
  resources :orders

  get '/search', to: 'searches#show'

  # namespace :reports do
  #   resources :transactions, only: [:index, :show]
  # end

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
  HighVoltage.configure do |config|
    config.route_drawer = HighVoltage::RouteDrawers::Root
    config.home_page    = 'home'
  end
end
