require 'rails_helper'

# Routes -----------------------------------------------------------------------
# POST   /supply_links(.:format)                       supply_links#create
# PATCH  /supply_links/:id(.:format)                   supply_links#update
# PUT    /supply_links/:id(.:format)                   supply_links#update
# DELETE /supply_links/:id(.:format)                   supply_links#destroy

describe 'SupplyLinks Endpoints', type: :request do
  let :acme  { create(:company) }
  let :ajax  { create(:company) }
  # admin
  let :alice { create(:user).tap { |u| acme.add_member(u, admin: true) } }
  # member
  let :bob   { create(:user).tap { |u| acme.add_member(u) } }

  context 'with anonymous user' do
    it 'always redirects to sign-in page' do
      post supply_links_path
      expect(response).to redirect_to(new_user_session_path)

      patch supply_link_path(anything)
      expect(response).to redirect_to(new_user_session_path)

      delete supply_link_path(anything)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with an admin user' do
    before(:each) { sign_in alice }

    it 'adds new purchasers/suppliers (pending confirmation)' do
      expect do
        post supply_links_path,
             params: { supply_link: { supplier: acme, purchaser: ajax } }
      end.to change(SupplyLink, :count).by(1)
      expect(SupplyLink.between(acme, ajax).confirmed?).to be(false)

      # What should the user see after adding a company?
      # expect(response).to redirect_to(company_path(company))
    end

  #   it 'cannot confirm member invitations' do
  #     expect do
  #       patch commitment_path(Commitment.between(carol, company)),
  #             params: { commitment: { pending_member_conf: false } }
  #     end.not_to change { Commitment.between(carol, company).confirmed? }.from(false)

  #     expect(response).to redirect_to(company_path(company))
  #   end

  #   it 'updates existing members' do
  #     expect do
  #       patch commitment_path(Commitment.between(bob, company)),
  #         params: { commitment: { admin: true } }
  #     end.to change { Commitment.between(bob, company).admin? }.from(false).to(true)
  #     expect(response).to redirect_to(company_path(company))
  #   end

  #   it 'deletes other members' do
  #     bob

  #     expect { delete commitment_path(Commitment.between(bob, company)) }
  #       .to change(Commitment, :count).by(-1)
  #     expect(response).to redirect_to(company_path(company))
  #   end
  end

  # context 'with a non-admin user' do
  #   before(:each) { sign_in bob }

  #   it 'shows index' do
  #     alice

  #     get company_commitments_path(company)
  #     expect(response.body).to have_xpath("//a[@href='#{user_path(alice)}']")
  #     expect(response.body).to have_xpath("//a[@href='#{user_path(bob)}']")
  #   end

  #   it 'adds new members (pending confirmation)' do
  #     expect do
  #       post company_commitments_path(company),
  #            params: { commitment: { user_id: eve.id } }
  #     end.to change(Commitment, :count).by(1)
  #     expect(Commitment.between(eve, company).confirmed?).to be(false)

  #     expect(response).to redirect_to(company_path(company))
  #   end

  #   it 'cannot update existing members' do
  #     expect do
  #       patch commitment_path(Commitment.between(bob, company)),
  #         params: { commitment: { admin: true } }
  #     end.not_to change { Commitment.between(bob, company).admin? }.from(false)
  #     expect(response).to redirect_to(company_path(company))
  #   end

  #   it 'deletes self' do
  #     expect { delete commitment_path(Commitment.between(bob, company)) }
  #       .to change(Commitment, :count).by(-1)
  #     expect(response).to redirect_to(company_path(company))
  #   end

  #   it 'cannot delete other members' do
  #     alice

  #     expect { delete commitment_path(Commitment.between(alice, company)) }
  #       .not_to change(Commitment, :count)
  #     expect(response).to redirect_to(company_path(company))
  #   end
  # end
end
