Rails.application.routes.draw do
  get 'supply_links/create'

  get 'supply_links/update'

  get 'supply_links/destroy'

  # Main Resources -------------------------------------------------------------
  resources :companies, except: [:index], shallow: true do
    resources :commitments, except: [:new, :edit, :show]
  end
  resources :supply_links, only: [:create, :update, :destroy]

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
