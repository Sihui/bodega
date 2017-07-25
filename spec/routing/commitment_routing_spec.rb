require 'rails_helper'

RSpec.describe 'commitment routing', type: :routing do
  it 'includes commitments#index' do
    expect(get: '/companies/1/commitments')
      .to route_to('commitments#index', company_id: '1')
  end

  it 'includes commitments#create' do
    expect(post: '/companies/1/commitments')
      .to route_to('commitments#create', company_id: '1')
  end

  it 'includes commitments#update' do
    expect(patch: '/commitments/1')
      .to route_to('commitments#update', id: '1')
  end

  it 'includes commitments#destroy' do
    expect(delete: '/commitments/1')
      .to route_to('commitments#destroy', id: '1')
  end
end
