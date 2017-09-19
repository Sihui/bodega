require 'rails_helper'

RSpec.describe 'devise account routing', type: :routing do
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
    expect(get: '/password/new').to route_to('devise/passwords#new')
  end

  it 'includes passwords#create' do
    expect(post: '/password').to route_to('devise/passwords#create')
  end

  it 'includes passwords#edit' do
    expect(get: '/password/edit').to route_to('devise/passwords#edit')
  end

  it 'includes passwords#update (via PATCH)' do
    expect(patch: '/password').to route_to('devise/passwords#update')
  end

  it 'includes passwords#update (via PUT)' do
    expect(put: '/password').to route_to('devise/passwords#update')
  end

  it 'includes registrations#new' do
    expect(get: '/join').to route_to('devise/registrations#new')
  end

  it 'includes registrations#update (via PATCH)' do
    expect(patch: '/account').to route_to('devise/registrations#update')
  end

  it 'includes registrations#update (via PUT)' do
    expect(put: '/account').to route_to('devise/registrations#update')
  end

  it 'includes registrations#destroy' do
    expect(delete: '/account').to route_to('devise/registrations#destroy')
  end

  it 'includes registrations#create' do
    expect(post: '/account').to route_to('devise/registrations#create')
  end
end
