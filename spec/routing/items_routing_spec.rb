require 'rails_helper'

RSpec.describe ItemsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/companies/1/items')
        .to route_to('items#index', company_id: '1')
    end

    it 'routes to #new' do
      expect(:get => '/companies/1/items/new')
        .to route_to('items#new', company_id: '1')
    end

    it 'routes to #show' do
      expect(:get => '/companies/1/items/1')
        .to route_to('items#show', company_id: '1', id: '1')
    end

    it 'routes to #edit' do
      expect(:get => '/companies/1/items/1/edit')
        .to route_to('items#edit', company_id: '1', id: '1')
    end

    it 'routes to #create' do
      expect(:post => '/companies/1/items')
        .to route_to('items#create', company_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(:put => '/companies/1/items/1')
        .to route_to('items#update', company_id: '1', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(:patch => '/companies/1/items/1')
        .to route_to('items#update', company_id: '1', id: '1')
    end

    it 'routes to #destroy' do
      expect(:delete => '/companies/1/items/1')
        .to route_to('items#destroy', company_id: '1', id: '1')
    end

  end
end
