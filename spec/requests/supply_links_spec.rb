require 'rails_helper'

# Routes -----------------------------------------------------------------------
# POST   /companies/:company_id/supply_links(.:format) supply_links#create
# PATCH  /supply_links/:id(.:format)                   supply_links#update
# PUT    /supply_links/:id(.:format)                   supply_links#update
# DELETE /supply_links/:id(.:format)                   supply_links#destroy

RSpec.describe 'SupplyLinks Endpoints', type: :request do
  context 'with anonymous user' do
    it 'always redirects to sign-in page' do
      post company_supply_links_path(acme)
      expect(response).to redirect_to new_account_session_path

      patch company_supply_link_path(acme, anything)
      expect(response).to redirect_to new_account_session_path

      delete company_supply_link_path(acme, anything)
      expect(response).to redirect_to new_account_session_path
    end
  end

  context 'with an admin user' do
    before(:each) { sign_in alice.account }

    it 'adds new purchasers/suppliers (pending confirmation)' do
      expect do
        post company_supply_links_path(acme),
             params: { supply_link: { supplier_id:  acme.id,
                                      purchaser_id: zorg.id,
                                      pending_supplier_conf: false } }
      end.to change(SupplyLink, :count).by 1

      expect(SupplyLink.last.confirmed?).to be false

      # TODO: What should the user see after adding a company?
      # expect(response).to redirect_to company_path(company)
    end

    it 'confirms pending invitations' do
      expect do
        patch company_supply_link_path(acme,
                                       SupplyLink.between(acme, cogswell)),
              params: { supply_link: { pending_supplier_conf: false } }
      end.to change { SupplyLink.between(acme, cogswell).confirmed? }.to true
    end

    it 'cannot re-add existing requests' do
      expect do
        post company_supply_links_path(acme),
             params: { supply_link: { supplier_id:  acme.id,
                                      purchaser_id: cogswell.id,
                                      pending_supplier_conf: false } }
      end.not_to change { cogswell.reload.supply_links.count }

      expect(response).to redirect_to acme
    end

    it 'cannot confirm requests initiated by own company' do
      sl = SupplyLink.between(acme, bluthco)

      expect do
        patch company_supply_link_path(acme, sl),
              params: { supply_link: { pending_supplier_conf:  false,
                                       pending_purchaser_conf: false } }
      end.not_to change { sl.reload.confirmed? }.from false

      # What should the user see after adding a company?
      # expect(response).to redirect_to company_path(company)
    end

    it 'cancels pending invitations/requests' do
      expect do
        delete company_supply_link_path(acme, SupplyLink.between(acme, cogswell))
      end.to change { cogswell.reload.supply_links.count }.by -1

      expect do
        delete company_supply_link_path(acme, SupplyLink.between(acme, bluthco))
      end.to change { bluthco.reload.supply_links.count }.by -1

      # What should the user see after adding a company?
      # expect(response).to redirect_to company_path(company)
    end
  end

  context 'with a non-admin user' do
    before(:each) { sign_in arthur.account }

    it 'cannot add new purchasers/suppliers' do
      expect do
        post company_supply_links_path(acme),
             params: { supply_link: { supplier_id:  acme.id,
                                      purchaser_id: zorg.id,
                                      pending_supplier_conf: false } }
      end.not_to change(SupplyLink, :count)

      # What should the user see after adding a company?
      # expect(response).to redirect_to company_path(company)
    end

    it 'cannot confirm pending invitations' do
      expect do
        patch company_supply_link_path(acme,
                                       SupplyLink.between(acme, cogswell)),
              params: { supply_link: { pending_supplier_conf: false } }
      end.not_to change { SupplyLink.between(acme, cogswell).confirmed? }

      # What should the user see after adding a company?
      # expect(response).to redirect_to company_path(company)
    end

    it 'cannot cancel pending invitations/requests' do
      expect do
        delete company_supply_link_path(acme, SupplyLink.between(acme, cogswell))
      end.not_to change { cogswell.reload.supply_links.count }

      # What should the user see after adding a company?
      # expect(response).to redirect_to company_path(company)
    end
  end

  context 'with a non-member user' do
    before(:each) { sign_in zack.account }

    it 'always redirects to company page' do
      post company_supply_links_path(acme)
      expect(response).to redirect_to company_path(acme)

      patch company_supply_link_path(acme, SupplyLink.between(acme, cogswell))
      expect(response).to redirect_to company_path(acme)

      delete company_supply_link_path(acme, SupplyLink.between(acme, cogswell))
      expect(response).to redirect_to company_path(acme)
    end
  end

  context 'with an admin of both companies' do
    before(:each) { sign_in aaron_burr.account }

    it 'always redirects to company page' do
      expect do
        post company_supply_links_path(acme),
             params: { supply_link: { supplier_id:  acme.id,
                                      purchaser_id: buynlarge.id,
                                      pending_supplier_conf: false,
                                      pending_purchaser_conf: false } }
      end.to change(SupplyLink, :count).by 1

      expect(SupplyLink.last.confirmed?).to be true
    end
  end
end
