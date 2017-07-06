require 'rails_helper'

RSpec.describe 'devise user routing', type: :routing do
  it 'includes sessions#new' do
    expect(get: '/sign_in').to route_to('devise/sessions#new')
  end

  it 'includes sessions#create' do
    expect(post: '/sign_in').to route_to('devise/sessions#create')
  end

  it 'includes sessions#destroy' do
    expect(delete: '/sign_out').to route_to('devise/sessions#destroy')
  end

  it 'includes passwords#new' do
    expect(get: '/reset_password').to route_to('devise/passwords#new')
  end

  it 'includes passwords#create' do
    expect(post: '/reset_password').to route_to('devise/passwords#create')
  end

  it 'includes registrations#new' do
    expect(get: '/sign_up').to route_to('devise/registrations#new')
  end

  it 'includes registrations#edit' do
    expect(get: '/user/edit').to route_to('devise/registrations#edit')
  end

  it 'includes registrations#show' do
    expect(get: '/user').to route_to('devise/registrations#show')
  end

  it 'includes registrations#update (via PATCH)' do
    expect(patch: '/user').to route_to('devise/registrations#update')
  end

  it 'includes registrations#destroy' do
    expect(delete: '/user').to route_to('devise/registrations#destroy')
  end

  it 'includes registrations#create' do
    expect(post: '/user').to route_to('devise/registrations#create')
  end
end
