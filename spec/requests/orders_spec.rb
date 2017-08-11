require 'rails_helper'

# Routes -----------------------------------------------------------------------
# GET    /orders(.:format)                                 orders#index
# POST   /orders(.:format)                                 orders#create
# GET    /orders/new(.:format)                             orders#new
# GET    /orders/:id/edit(.:format)                        orders#edit
# GET    /orders/:id(.:format)                             orders#show
# PATCH  /orders/:id(.:format)                             orders#update
# PUT    /orders/:id(.:format)                             orders#update
# DELETE /orders/:id(.:format)                             orders#destroy

RSpec.describe 'Orders Endpoints', type: :request do
  let :existing_order do
    create(:order, :populated, supplier: acme, purchaser: cyberdyne)
  end

  let :accepted_order do
    existing_order.tap { |r| r.update(accepted_by: alice) }
  end

  let :disputed_order do
    accepted_order.tap { |r| r.line_items.take(2).each { |r| r.update(qty_disputed: 3) } }
  end

  context 'with anonymous user' do
    it 'always redirects to sign-in page' do
      get orders_path
      expect(response).to redirect_to(new_user_session_path)

      post orders_path
      expect(response).to redirect_to(new_user_session_path)

      get new_order_path
      expect(response).to redirect_to(new_user_session_path)

      get edit_order_path(anything)
      expect(response).to redirect_to(new_user_session_path)

      get order_path(anything)
      expect(response).to redirect_to(new_user_session_path)

      patch order_path(anything)
      expect(response).to redirect_to(new_user_session_path)

      put order_path(anything)
      expect(response).to redirect_to(new_user_session_path)

      delete order_path(anything)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with an admin user (of supplier)' do
    before :each { sign_in alice }

    # CREATE
    it 'diverts from new order form' do
      get new_order_path, params: { order: { purchaser_id: cyberdyne.id,
                                             supplier_id:  acme.id } }
      expect(response.body).to redirect_to orders_path
    end

    it 'diverts from creating new orders' do
      expect do
        post orders_path, params: { order: { purchaser_id: cyberdyne.id,
                                             supplier_id: acme.id } }
      end.not_to change(Order, :count)
      expect(response).to redirect_to orders_path
    end

    # READ
    it 'displays index' do
      pending('view creation')

      get orders_path
      # What is the bare minimum that the index should display?
      # expect(response.body)
      #   .to have_xpath("//a[@href='#{company_item_path(acme, inventory[0])}']")
      # expect(response.body)
      #   .to have_xpath("//a[@href='#{company_item_path(acme, inventory[1])}']")
      fail
    end

    it 'displays an order summary' do
      pending('view creation')

      get order_path(anything)
      expect(response.body).to match(order.invoice)
    end

    # UPDATE
    it 'displays the edit order form' do
      pending('view creation')

      get edit_order_path(anything)
      expect(response.body)
        .to have_xpath("//form[@action='#{order_path(order)}'][@method='post']")
    end

    it 'accepts an existing order' do
      expect do
        patch order_path(existing_order),
          params: { order: { id: existing_order.id }, update_action: 'accepting' }
      end.to change { existing_order.reload.confirmed? }.to true
    end

    it 'applies a fixed discount to an existing order' do
      expect do
        patch order_path(existing_order),
          params: { order: { discount: 100, discount_type: 'fixed' },
                    update_action: 'discounting' }
      end.to change { existing_order.reload.total }.by(-100)
    end

    it 'applies a percentage discount to an existing order' do
      expect do
        patch order_path(existing_order),
          params: { order: { discount: 10, discount_type: 'percentage' },
                    update_action: 'discounting' }
      end.to change { existing_order.reload.total }.to(0.9 * existing_order.total)
    end

    it 'downsizes an existing order (and implicitly accepts)' do
      updated_lis = existing_order.line_items.take(2).each { |r| r.qty = 0 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'downsizing' }
      end.to change(LineItem, :count).by(-2)
        .and change { existing_order.reload.confirmed? }.to true
    end

    it 'comps existing order items' do
      updated_lis = existing_order.line_items.take(1).each { |r| r.comp! }
      params = updated_lis.map { |r| r.as_json(only: [:id, :comped]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'discounting' }
      end.to change { existing_order.total }.by(updated_lis.first.line_total * -1)
    end

    it 'resolves disputed orders' do
      updated_lis = disputed_order.line_items.where("qty_disputed IS NOT NULL")
        .each { |r| r.qty = r.qty_disputed }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(disputed_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'resolving' }
      end.to change { disputed_order.reload.disputed? }.from(true).to(false)
    end

    it 'diverts from upsizing an existing order' do
      updated_lis = existing_order.line_items.take(2).each { |r| r.qty += 1 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'downsizing' }
      end.not_to change { existing_order.total }
      expect(response).to redirect_to(existing_order)
    end

    it 'diverts from amending an order' do
      updated_lis = existing_order.line_items.take(2).each { |r| r.qty += 1 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'amending' }
      end.not_to change { existing_order.total }
    end

    it 'diverts from disputing order' do
      updated_lis = existing_order.line_items.take(2).each { |r| r.qty_disputed = 0 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty_disputed]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'disputing' }
      end.not_to change { existing_order.disputed? }
    end

    # DESTROY
    it 'diverts from deleting an existing order' do
      existing_order

      expect { delete order_path(existing_order) }.not_to change(Order, :count)
      expect(response).to redirect_to(orders_path)
    end
  end

  context 'with a non-admin user (of supplier)' do
    before(:each) { sign_in arthur }

    # CREATE
    it 'diverts from new order form' do
      get new_order_path, params: { order: { purchaser_id: cyberdyne.id,
                                             supplier_id:  acme.id } }
      expect(response.body).to redirect_to orders_path
    end

    it 'diverts from creating new orders' do
      expect do
        post orders_path, params: { order: { purchaser_id: cyberdyne.id,
                                             supplier_id: acme.id } }
      end.not_to change(Order, :count)
      expect(response).to redirect_to orders_path
    end

    # READ
    it 'displays index' do
      pending('view creation')

      get orders_path
      # What is the bare minimum that the index should display?
      # expect(response.body)
      #   .to have_xpath("//a[@href='#{company_item_path(acme, inventory[0])}']")
      # expect(response.body)
      #   .to have_xpath("//a[@href='#{company_item_path(acme, inventory[1])}']")
      fail
    end

    it 'displays an order summary' do
      pending('view creation')

      get order_path(anything)
      expect(response.body).to match(order.invoice)
    end

    # UPDATE
    it 'displays the edit order form' do
      pending('view creation')

      get edit_order_path(anything)
      expect(response.body)
        .to have_xpath("//form[@action='#{order_path(order)}'][@method='post']")
    end

    it 'accepts an existing order' do
      expect do
        patch order_path(existing_order),
          params: { order: { id: existing_order.id }, update_action: 'accepting' }
      end.to change { existing_order.reload.confirmed? }.to true
    end

    it 'applies a fixed discount to an existing order' do
      expect do
        patch order_path(existing_order),
          params: { order: { discount: 100, discount_type: 'fixed' },
                    update_action: 'discounting' }
      end.to change { existing_order.reload.total }.by(-100)
    end

    it 'applies a percentage discount to an existing order' do
      expect do
        patch order_path(existing_order),
          params: { order: { discount: 10, discount_type: 'percentage' },
                    update_action: 'discounting' }
      end.to change { existing_order.reload.total }.to(0.9 * existing_order.total)
    end

    it 'downsizes an existing order (and implicitly accepts)' do
      updated_lis = existing_order.line_items.take(2).each { |r| r.qty = 0 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'downsizing' }
      end.to change(LineItem, :count).by(-2)
        .and change { existing_order.reload.confirmed? }.to true
    end

    it 'comps existing order items' do
      updated_lis = existing_order.line_items.take(1).each { |r| r.comp! }
      params = updated_lis.map { |r| r.as_json(only: [:id, :comped]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'discounting' }
      end.to change { existing_order.total }.by(updated_lis.first.line_total * -1)
    end

    it 'resolves disputed orders' do
      updated_lis = disputed_order.line_items.take(2).each { |r| r.qty = 3 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(disputed_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'resolving' }
      end.to change { disputed_order.reload.disputed? }.from(true).to(false)
    end

    it 'diverts from upsizing an existing order' do
      updated_lis = existing_order.line_items.take(2).each { |r| r.qty += 1 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'downsizing' }
      end.not_to change { existing_order.total }
      expect(response).to redirect_to(existing_order)
    end

    it 'diverts from amending an order' do
      updated_lis = existing_order.line_items.take(2).each { |r| r.qty += 1 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'amending' }
      end.not_to change { existing_order.total }
    end

    it 'diverts from disputing order' do
      updated_lis = existing_order.line_items.take(2).each { |r| r.qty_disputed = 0 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty_disputed]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'disputing' }
      end.not_to change { existing_order.disputed? }
    end

    # DESTROY
    it 'diverts from deleting an existing order' do
      existing_order

      expect { delete order_path(existing_order) }.not_to change(Order, :count)
      expect(response).to redirect_to(orders_path)
    end
  end

  context 'with a non-admin member (of purchaser)' do
    before(:each) { sign_in carol }

    # CREATE
    it 'displays the new order form' do
      get new_order_path,
          params: { order: { supplier_id: acme.id, purchaser_id: cyberdyne.id, } }
      expect(response.body)
        .to have_xpath("//form[@action='#{orders_path}'][@method='post']")
    end

    it 'creates a new order' do
      # initialize supplier inventory
      create_list(:item, 5, supplier: acme)
      # order params
      params = { supplier_id: acme.id, purchaser_id: cyberdyne.id,
                 line_items_attributes: [{ item_id: acme.items[0].id,
                                           qty: 2 },
                                         { item_id: acme.items[1].id,
                                           qty: 1 }].to_yaml }

      expect { post orders_path, params: { order: params } }
        .to change(Order, :count).by(1)
        .and change(LineItem, :count).by(2)
      expect(Order.last.placed_by).to eq carol
    end

    # READ
    it 'displays index' do
      pending('view creation')

      get orders_path
      # What is the bare minimum that the index should display?
      # expect(response.body)
      #   .to have_xpath("//a[@href='#{company_item_path(acme, inventory[0])}']")
      # expect(response.body)
      #   .to have_xpath("//a[@href='#{company_item_path(acme, inventory[1])}']")
      fail
    end

    it 'displays an order summary' do
      pending('view creation')

      get order_path(anything)
      expect(response.body).to match(order.invoice)
    end

    # UPDATE
    it 'displays the edit order form' do
      pending('view creation')

      get edit_order_path(anything)
      expect(response.body)
        .to have_xpath("//form[@action='#{order_path(order)}'][@method='post']")
    end

    it 'amends an existing order' do
      updated_lis = existing_order.line_items.take(2).each { |r| r.qty += 1 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'amending' }
      end.to change { existing_order.reload.total }
        .by(existing_order.line_items.take(2).map(&:price).reduce(:+))
    end

    it 'disputes a accepted order' do
      updated_lis = accepted_order.line_items.take(2).each { |r| r.qty_disputed = 0 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty_disputed]) }.to_yaml

      expect do
        patch order_path(accepted_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'disputing' }
      end.to change { accepted_order.reload.disputed? }.from(false)
    end

    it 'diverts from accepting an existing order' do
      expect do
        patch order_path(existing_order),
          params: { order: { id: existing_order.id }, update_action: 'accepting' }
      end.not_to change { existing_order.reload.confirmed? }.from false
    end

    it 'diverts from discounting an existing order' do
      expect do
        patch order_path(existing_order),
          params: { order: { discount: 100, discount_type: 'fixed' },
                    update_action: 'discounting' }
      end.not_to change { existing_order.reload.total }
    end

    it 'diverts from comping existing order items' do
      updated_lis = existing_order.line_items.take(1).each { |r| r.comp! }
      params = updated_lis.map { |r| r.as_json(only: [:id, :comped]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'discounting' }
      end.not_to change { existing_order.total }
    end

    it 'diverts from downsizing (and implicitly accepting) an existing order' do
      updated_lis = existing_order.line_items.take(2).each { |r| r.qty = 0 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(existing_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'downsizing' }
      end.not_to change(LineItem, :count)

      expect(existing_order.reload.confirmed?).to be false
    end

    it 'diverts from resolving disputed orders' do
      updated_lis = disputed_order.line_items.take(2).each { |r| r.qty = 3 }
      params = updated_lis.map { |r| r.as_json(only: [:id, :qty]) }.to_yaml

      expect do
        patch order_path(disputed_order),
          params: { order: { line_items_attributes: params },
                    update_action: 'resolving' }
      end.not_to change { disputed_order.reload.disputed? }.from true
    end

    # DESTROY
    it 'cancels an existing order' do
      existing_order

      expect { delete order_path(existing_order) }.to change(Order, :count).by -1
      expect(response).to redirect_to(orders_path)
    end

    it 'diverts from cancelling an already-accepted order' do
      accepted_order

      expect { delete order_path(accepted_order) }.not_to change(Order, :count)
      expect(response).to redirect_to(orders_path)
    end
  end

  context 'with an unaffiliated user' do
    before(:each) { sign_in zack }

    # CREATE
    it 'diverts from new order form' do
      get new_order_path, params: { order: { purchaser_id: cyberdyne.id,
                                             supplier_id: acme.id} }
      expect(response).to redirect_to home_path
    end

    it 'diverts from creating orders' do
      expect do
        post orders_path, params: { order: { purchaser_id: cyberdyne.id,
                                             supplier_id: acme.id} }
      end.not_to change(Order, :count)
      expect(response).to redirect_to home_path
    end

    # READ
    it 'diverts from index' do
      get orders_path
      expect(response).to redirect_to home_path
    end

    it 'diverts from order summary' do
      get order_path(create(:order, supplier: acme))
      expect(response).to redirect_to home_path
    end

    # UPDATE
    it 'diverts from edit order form' do
      get edit_order_path(create(:order, supplier: acme))
      expect(response).to redirect_to home_path
    end

    it 'diverts from updating orders (PATCH)' do
      expect { patch order_path(create(:order, supplier: acme)) }
        .not_to change(LineItem, :count)
      expect(response).to redirect_to home_path
    end

    it 'diverts from updating orders (PUT)' do
      expect { put order_path(create(:order, supplier: acme)) }
        .not_to change(LineItem, :count)
      expect(response).to redirect_to home_path
    end

    # DESTROY
    it 'diverts from destroying orders' do
      expect { delete order_path(create(:order, supplier: acme)) }
        .not_to change(LineItem, :count)
      expect(response).to redirect_to home_path
    end
  end
end
