require 'rails_helper'

# Routes -----------------------------------------------------------------------
# POST   /companies/:company_id/supply_links(.:format) supply_links#create
# PATCH  /supply_links/:id(.:format)                   supply_links#update
# PUT    /supply_links/:id(.:format)                   supply_links#update
# DELETE /supply_links/:id(.:format)                   supply_links#destroy

describe 'SupplyLinks Endpoints', type: :request do
  let :acme      { create(:company) }
  let :buynlarge { create(:company) }
  let :cyberdyne { create(:company).tap { |c| c.add_supplier(acme) } }
  let :duff      { create(:company).tap { |c| acme.add_supplier(c) } }
  let :encom     { create(:company).tap { |c| acme.add_supplier(c, pending: :none) } }
  # admin
  let :alice     { create(:user).tap { |u| acme.add_member(u, admin: true) } }
  # member
  let :bob       { create(:user).tap { |u| acme.add_member(u) } }
  # non-member
  let :carol     { create(:user) }
  # dual-admin
  let :david     { create(:user).tap { |u| acme.add_member(u, admin: true)
                                           buynlarge.add_member(u, admin: true) } }

  context 'with anonymous user' do
    it 'always redirects to sign-in page' do
      post company_supply_links_path(acme)
      expect(response).to redirect_to(new_user_session_path)

      patch company_supply_link_path(acme, anything)
      expect(response).to redirect_to(new_user_session_path)

      delete company_supply_link_path(acme, anything)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with an admin user' do
    before(:each) { sign_in alice }

    it 'adds new purchasers/suppliers (pending confirmation)' do
      expect do
        post company_supply_links_path(acme),
             params: { supply_link: { supplier_id:  acme.id,
                                      purchaser_id: buynlarge.id,
                                      pending_supplier_conf: false } }
      end.to change(SupplyLink, :count).by(1)
      expect(SupplyLink.between(acme, buynlarge).confirmed?).to be(false)

      # What should the user see after adding a company?
      # expect(response).to redirect_to(company_path(company))
    end

    it 'confirms pending invitations' do
      expect do
        patch company_supply_link_path(acme,
                                       SupplyLink.between(acme, cyberdyne)),
              params: { supply_link: { supplier_id:  acme.id,
                                       purchaser_id: cyberdyne.id,
                                       pending_supplier_conf: false } }
      end.to change { SupplyLink.between(acme, cyberdyne).confirmed? }.to(true)

      # What should the user see after adding a company?
      # expect(response).to redirect_to(company_path(company))
    end

    it 'cannot re-add existing requests' do
      cyberdyne     # initialize supply link

      expect do
        post company_supply_links_path(acme),
             params: { supply_link: { supplier_id:  acme.id,
                                      purchaser_id: cyberdyne.id,
                                      pending_supplier_conf: false } }
      end.not_to change(SupplyLink, :count)
      expect(SupplyLink.between(acme, cyberdyne).confirmed?).to be(false)

      # What should the user see after adding a company?
      # expect(response).to redirect_to(company_path(company))
    end

    it 'cannot confirm requests initiated by own company' do
      expect do
        patch company_supply_link_path(acme,
                                       SupplyLink.between(acme, duff)),
              params: { supply_link: { supplier_id:  acme.id,
                                       purchaser_id: duff.id,
                                       pending_supplier_conf:  false,
                                       pending_purchaser_conf: false } }
      end.not_to change { SupplyLink.between(acme, duff).confirmed? }.from(false)

      # What should the user see after adding a company?
      # expect(response).to redirect_to(company_path(company))
    end

    it 'cancels pending invitations/requests' do
      cyberdyne     # initialize supply links
      duff

      expect do
        delete company_supply_link_path(acme, SupplyLink.between(acme, cyberdyne))
      end.to change(SupplyLink, :count).by(-1)

      expect do
        delete company_supply_link_path(acme, SupplyLink.between(acme, duff))
      end.to change(SupplyLink, :count).by(-1)

      # What should the user see after adding a company?
      # expect(response).to redirect_to(company_path(company))
    end
  end

  context 'with a non-admin user' do
    before(:each) { sign_in bob }

    it 'cannot add new purchasers/suppliers' do
      expect do
        post company_supply_links_path(acme),
             params: { supply_link: { supplier_id:  acme.id,
                                      purchaser_id: buynlarge.id,
                                      pending_supplier_conf: false } }
      end.not_to change(SupplyLink, :count)

      # What should the user see after adding a company?
      # expect(response).to redirect_to(company_path(company))
    end

    it 'cannot confirm pending invitations' do
      expect do
        patch company_supply_link_path(acme,
                                       SupplyLink.between(acme, cyberdyne)),
              params: { supply_link: { supplier_id:  acme.id,
                                       purchaser_id: cyberdyne.id,
                                       pending_supplier_conf: false } }
      end.not_to change { SupplyLink.between(acme, cyberdyne).confirmed? }

      # What should the user see after adding a company?
      # expect(response).to redirect_to(company_path(company))
    end

    it 'cannot cancel pending invitations/requests' do
      cyberdyne     # initialize supply links

      expect do
        delete company_supply_link_path(acme, SupplyLink.between(acme, cyberdyne))
      end.not_to change(SupplyLink, :count)

      # What should the user see after adding a company?
      # expect(response).to redirect_to(company_path(company))
    end
  end

  context 'with a non-member user' do
    before(:each) { sign_in carol }

    it 'always redirects to company page' do
      post company_supply_links_path(acme)
      expect(response).to redirect_to(company_path(acme))

      patch company_supply_link_path(acme, SupplyLink.between(acme, cyberdyne))
      expect(response).to redirect_to(company_path(acme))

      delete company_supply_link_path(acme, SupplyLink.between(acme, cyberdyne))
      expect(response).to redirect_to(company_path(acme))
    end
  end

  context 'with an admin of both companies' do
    before(:each) { sign_in david }

    it 'always redirects to company page' do
      expect do
        post company_supply_links_path(acme),
             params: { supply_link: { supplier_id:  acme.id,
                                      purchaser_id: buynlarge.id,
                                      pending_supplier_conf: false,
                                      pending_purchaser_conf: false } }
      end.to change(SupplyLink, :count).by(1)
      expect(SupplyLink.between(acme, buynlarge).confirmed?).to be(true)
    end
  end
end
