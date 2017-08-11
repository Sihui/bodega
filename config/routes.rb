Rails.application.routes.draw do
  # Main Resources -------------------------------------------------------------
  resources :companies, except: [:index] do
    resources :commitments, except: [:new, :edit, :show], shallow: true
    resources :supply_links, only: [:create, :update, :destroy]
    resources :items
  end

  resources :orders

  # Authentication -------------------------------------------------------------
  devise_for :users, path: '', path_names: { registration: :users },
                               skip: [:passwords, :registrations]

  as :user do
    get    '/reset_password', to: 'devise/passwords#new',    as: :new_user_password
    post   '/reset_password', to: 'devise/passwords#create', as: :user_password

    get    '/sign_up',   to: 'devise/registrations#new',     as: :new_user_registration
    get    '/user/edit', to: 'devise/registrations#edit',    as: :edit_user_registration
    get    '/user',      to: 'devise/registrations#show',    as: :user_registration
    patch  '/user',      to: 'devise/registrations#update',  as: ''
    delete '/user',      to: 'devise/registrations#destroy', as: ''
    post   '/user',      to: 'devise/registrations#create',  as: ''
  end

  # Static pages ---------------------------------------------------------------
  HighVoltage.configure do |config|
    config.route_drawer = HighVoltage::RouteDrawers::Root
    config.home_page    = 'home'
  end
end
