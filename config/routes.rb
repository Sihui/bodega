Rails.application.routes.draw do
  # Main Resources -------------------------------------------------------------
  resources :users, only: [:show, :update]
  resources :companies, except: [:index] do
    resources :commitments, except: [:new, :edit, :show], shallow: true
    resources :supply_links, only: [:create, :update, :destroy]
    resources :items
  end
  resources :orders

  namespace :reports do
    resources :transactions, only: [:index, :show]
  end

  # Authentication -------------------------------------------------------------
  # See https://github.com/plataformatec/devise#configuring-routes
  devise_for :accounts, path: '', skip: [:registrations]

  devise_scope :account do
    get    '/join',      to: 'devise/registrations#new',     as: :new_account_registration
    post   '/account',   to: 'devise/registrations#create',  as: :account_registration
    patch  '/account',   to: 'devise/registrations#update',  as: ''
    put    '/account',   to: 'devise/registrations#update',  as: ''
    delete '/account',   to: 'devise/registrations#destroy', as: ''
  end

  # get '/account', to: redirect('/join')

  # Static pages ---------------------------------------------------------------
  HighVoltage.configure do |config|
    config.route_drawer = HighVoltage::RouteDrawers::Root
    config.home_page    = 'home'
  end
end
