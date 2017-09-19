require 'rails_helper'

# Routes -----------------------------------------------------------------------
# GET    /companies/:company_id/items(.:format)            items#index
# POST   /companies/:company_id/items(.:format)            items#create
# GET    /companies/:company_id/items/new(.:format)        items#new
# GET    /companies/:company_id/items/:id/edit(.:format)   items#edit
# GET    /companies/:company_id/items/:id(.:format)        items#show
# PATCH  /companies/:company_id/items/:id(.:format)        items#update
# PUT    /companies/:company_id/items/:id(.:format)        items#update
# DELETE /companies/:company_id/items/:id(.:format)        items#destroy

RSpec.describe 'Items Endpoints', type: :request do
  let :inventory { create_list(:item, 20, supplier: acme) }

  context 'with anonymous user' do
    it 'always redirects to sign-in page' do
      get company_items_path(acme)                #index
      expect(response).to redirect_to(new_account_session_path)

      post company_items_path(acme)               #create
      expect(response).to redirect_to(new_account_session_path)

      get new_company_item_path(acme)             #new
      expect(response).to redirect_to(new_account_session_path)

      get edit_company_item_path(acme, anything)  #edit
      expect(response).to redirect_to(new_account_session_path)

      get company_item_path(acme, anything)       #show
      expect(response).to redirect_to(new_account_session_path)

      patch company_item_path(acme, anything)     #update
      expect(response).to redirect_to(new_account_session_path)

      delete company_item_path(acme, anything)    #destroy
      expect(response).to redirect_to(new_account_session_path)
    end
  end

  context 'with own company admin' do
    before(:each) { sign_in alice.account }

    it 'displays the index' do
      inventory

      get company_items_path(acme)
      expect(response.body)
        .to have_xpath("//a[@href='#{company_item_path(acme, inventory[0])}']")
      expect(response.body)
        .to have_xpath("//a[@href='#{company_item_path(acme, inventory[1])}']")
    end

    it 'adds new inventory items' do
      expect do
        post company_items_path(acme),
             params: { item: { name: 'Aioli',
                               ref_code: 'AIOL',
                               price: 350,
                               unit_size: '2kg' } }
      end.to change(Item, :count).by(1)
    end

    it 'displays a new inventory item form' do
      get new_company_item_path(acme)
      expect(response.body)
        .to have_xpath("//form[@action='#{company_items_path(acme)}']"\
                             "[@method='post']")
    end

    it 'displays an edit inventory item form' do
      get edit_company_item_path(acme, inventory.first)
      expect(response.body)
        .to have_xpath("//form[@action='#{company_item_path(acme, inventory[0])}']"\
                             "[@method='post']")
    end

    it 'displays item information' do
      get company_item_path(acme, inventory.first)
      expect(response.body).to match(inventory.first.name)
    end

    it 'updates existing inventory items' do
      expect do
        patch company_item_path(acme, inventory.first),
               params: { item: { name: 'Aioli',
                                 ref_code: 'AIOL',
                                 price: 350,
                                 unit_size: '2kg' } }
      end.to change { inventory.first.reload.name }.to('Aioli')
    end

    it 'deletes existing inventory items' do
      inventory
      expect { delete company_item_path(acme, inventory.first) }
        .to change(Item, :count).by(-1)
    end
  end

  context 'with own company member' do
    before(:each) { sign_in arthur.account }

    it 'displays the index' do
      inventory

      get company_items_path(acme)
      expect(response.body)
        .to have_xpath("//a[@href='#{company_item_path(acme, inventory[0])}']")
      expect(response.body)
        .to have_xpath("//a[@href='#{company_item_path(acme, inventory[1])}']")
    end

    it 'cannot add new inventory items' do
      expect do
        post company_items_path(acme),
             params: { item: { name: 'Aioli',
                               ref_code: 'AIOL',
                               price: 350,
                               unit_size: '2kg' } }
      end.not_to change(Item, :count)
    end

    it 'diverts from new inventory item form' do
      get new_company_item_path(acme)
      expect(response.body).to redirect_to(company_items_path(acme))
    end

    it 'diverts from edit inventory item form' do
      get edit_company_item_path(acme, inventory.first)
      expect(response.body).to redirect_to(company_items_path(acme))
    end

    it 'displays item information' do
      get company_item_path(acme, inventory.first)
      expect(response.body).to match(inventory.first.name)
    end

    it 'cannot update existing inventory items' do
      patch company_item_path(acme, inventory.first),
             params: { item: { name: 'Aioli',
                               ref_code: 'AIOL',
                               price: 350,
                               unit_size: '2kg' } }
      expect(response.body).to redirect_to(company_items_path(acme))
    end

    it 'cannot delete existing inventory items' do
      inventory
      expect { delete company_item_path(acme, inventory.first) }
        .not_to change(Item, :count)
    end
  end

  context 'with an unaffiliated user' do
    before(:each) { sign_in zack.account }

    it 'diverts from the index' do
      get company_items_path(acme)
      expect(response.body).to redirect_to(company_path(acme))
    end

    it 'cannot add new inventory items' do
      expect do
        post company_items_path(acme),
             params: { item: { name: 'Aioli',
                               ref_code: 'AIOL',
                               price: 350,
                               unit_size: '2kg' } }
      end.not_to change(Item, :count)
    end

    it 'diverts from new inventory item form' do
      get new_company_item_path(acme)
      expect(response.body).to redirect_to(company_path(acme))
    end

    it 'diverts from edit inventory item form' do
      get edit_company_item_path(acme, inventory.first)
      expect(response.body).to redirect_to(company_path(acme))
    end

    it 'diverts from item information' do
      get company_item_path(acme, inventory.first)
      expect(response.body).to redirect_to(company_path(acme))
    end

    it 'cannot update existing inventory items' do
      expect do
        patch company_item_path(acme, inventory.first),
               params: { item: { name: 'Aioli',
                                 ref_code: 'AIOL',
                                 price: 350,
                                 unit_size: '2kg' } }
      end.not_to change { inventory.first.reload }
      expect(response.body).to redirect_to(company_path(acme))
    end

    it 'cannot delete existing inventory items' do
      inventory
      expect { delete company_item_path(acme, inventory.first) }
        .not_to change(Item, :count)
    end
  end

  context 'with a member of a supplier' do
    before(:each) { sign_in bob.account }

    it 'diverts from the index' do
      get company_items_path(acme)
      expect(response.body).to redirect_to(company_path(acme))
    end

    it 'cannot add new inventory items' do
      expect do
        post company_items_path(acme),
             params: { item: { name: 'Aioli',
                               ref_code: 'AIOL',
                               price: 350,
                               unit_size: '2kg' } }
      end.not_to change(Item, :count)
    end

    it 'diverts from new inventory item form' do
      get new_company_item_path(acme)
      expect(response.body).to redirect_to(company_path(acme))
    end

    it 'diverts from edit inventory item form' do
      get edit_company_item_path(acme, inventory.first)
      expect(response.body).to redirect_to(company_path(acme))
    end

    it 'diverts from item information' do
      get company_item_path(acme, inventory.first)
      expect(response.body).to redirect_to(company_path(acme))
    end

    it 'cannot update existing inventory items' do
      expect do
        patch company_item_path(acme, inventory.first),
               params: { item: { name: 'Aioli',
                                 ref_code: 'AIOL',
                                 price: 350,
                                 unit_size: '2kg' } }
      end.not_to change { inventory.first.reload }
      expect(response.body).to redirect_to(company_path(acme))
    end

    it 'cannot delete existing inventory items' do
      inventory
      expect { delete company_item_path(acme, inventory.first) }
        .not_to change(Item, :count)
    end
  end

  context 'with a member of a purchaser' do
    before(:each) { sign_in carol.account }

    it 'displays the index' do
      inventory

      get company_items_path(acme)
      expect(response.body)
        .to have_xpath("//a[@href='#{company_item_path(acme, inventory[0])}']")
      expect(response.body)
        .to have_xpath("//a[@href='#{company_item_path(acme, inventory[1])}']")
    end

    it 'cannot add new inventory items' do
      expect do
        post company_items_path(acme),
             params: { item: { name: 'Aioli',
                               ref_code: 'AIOL',
                               price: 350,
                               unit_size: '2kg' } }
      end.not_to change(Item, :count)
    end

    it 'diverts from new inventory item form' do
      get new_company_item_path(acme)
      expect(response.body).to redirect_to(company_items_path(acme))
    end

    it 'diverts from edit inventory item form' do
      get edit_company_item_path(acme, inventory.first)
      expect(response.body).to redirect_to(company_items_path(acme))
    end

    it 'displays item information' do
      get company_item_path(acme, inventory.first)
      expect(response.body).to match(inventory.first.name)
    end

    it 'cannot update existing inventory items' do
      patch company_item_path(acme, inventory.first),
             params: { item: { name: 'Aioli',
                               ref_code: 'AIOL',
                               price: 350,
                               unit_size: '2kg' } }
      expect(response.body).to redirect_to(company_items_path(acme))
    end

    it 'cannot delete existing inventory items' do
      inventory
      expect { delete company_item_path(acme, inventory.first) }
        .not_to change(Item, :count)
    end
  end
end
