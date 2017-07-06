require 'rails_helper'

RSpec.describe 'company routing', type: :routing do
  it 'includes #index' do
    expect(get: '/companies').to route_to('companies#index')
  end

  it 'includes #create' do
    expect(post: '/companies').to route_to('companies#create')
  end

  it 'includes #new' do
    expect(get: '/companies/new').to route_to('companies#new')
  end

  it 'includes #edit' do
    expect(get: '/companies/1/edit').to route_to('companies#edit', id: '1')
  end

  it 'includes #show' do
    expect(get: '/companies/1').to route_to('companies#show', id: '1')
  end

  it 'includes #destroy' do
    expect(delete: '/companies/1').to route_to('companies#destroy', id: '1')
  end

  it 'includes #update (via PATCH)' do
    expect(patch: '/companies/1').to route_to('companies#update', id: '1')
  end
end
