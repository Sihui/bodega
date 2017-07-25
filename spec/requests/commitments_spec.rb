require 'rails_helper'

# Routes -----------------------------------------------------------------------
# GET    /companies/:company_id/commitments(.:format) commitments#index
# POST   /companies/:company_id/commitments(.:format) commitments#create
# PATCH  /commitments/:id(.:format)                   commitments#update
# PUT    /commitments/:id(.:format)                   commitments#update
# DELETE /commitments/:id(.:format)                   commitments#destroy

describe 'Commitments Endpoints', type: :request do
  let :company { create(:company) }
  # admin
  let :alice   { create(:user).tap { |u| company.add_member(u, admin: true) } }
  # member
  let :bob     { create(:user).tap { |u| company.add_member(u) } }
  # non-member (with invitation)
  let :carol   { create(:user).tap { |u| company.add_member(u, pending: :member) } }
  # non-member (with open request)
  let :david   { create(:user).tap { |u| company.add_member(u, pending: :admin) } }
  # non-member
  let :eve     { create(:user) }

  context 'with anonymous user' do
    it 'always redirects to sign-in page' do
      get company_commitments_path(company)
      expect(response).to redirect_to(new_user_session_path)

      post company_commitments_path(company)
      expect(response).to redirect_to(new_user_session_path)

      patch commitment_path(alice.commitments.first)
      expect(response).to redirect_to(new_user_session_path)

      delete commitment_path(alice.commitments.first)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with an admin user' do
    before(:each) { sign_in alice }

    it 'shows index' do
      bob

      get company_commitments_path(company)
      expect(response.body).to have_xpath("//a[@href='#{user_path(alice)}']")
      expect(response.body).to have_xpath("//a[@href='#{user_path(bob)}']")
    end

    it 'adds new members (pending confirmation)' do
      expect do
        post company_commitments_path(company),
             params: { commitment: { user_id: eve.id } }
      end.to change(Commitment, :count).by(1)
      expect(Commitment.between(eve, company).confirmed?).to be(false)

      expect(response).to redirect_to(company_path(company))
    end

    it 'cannot confirm member invitations' do
      expect do
        patch commitment_path(Commitment.between(carol, company)),
              params: { commitment: { pending_member_conf: false } }
      end.not_to change { Commitment.between(carol, company).confirmed? }.from(false)

      expect(response).to redirect_to(company_path(company))
    end

    it 'updates existing members' do
      expect do
        patch commitment_path(Commitment.between(bob, company)),
          params: { commitment: { admin: true } }
      end.to change { Commitment.between(bob, company).admin? }.from(false).to(true)
      expect(response).to redirect_to(company_path(company))
    end

    it 'deletes other members' do
      bob

      expect { delete commitment_path(Commitment.between(bob, company)) }
        .to change(Commitment, :count).by(-1)
      expect(response).to redirect_to(company_path(company))
    end
  end

  context 'with a non-admin user' do
    before(:each) { sign_in bob }

    it 'shows index' do
      alice

      get company_commitments_path(company)
      expect(response.body).to have_xpath("//a[@href='#{user_path(alice)}']")
      expect(response.body).to have_xpath("//a[@href='#{user_path(bob)}']")
    end

    it 'cannot add new members' do
      expect do
        post company_commitments_path(company),
             params: { commitment: { user_id: eve.id } }
      end.not_to change(Commitment, :count)

      expect(response).to redirect_to(company_path(company))
    end

    it 'cannot update existing members' do
      expect do
        patch commitment_path(Commitment.between(bob, company)),
          params: { commitment: { admin: true } }
      end.not_to change { Commitment.between(bob, company).admin? }.from(false)
      expect(response).to redirect_to(company_path(company))
    end

    it 'deletes self' do
      expect { delete commitment_path(Commitment.between(bob, company)) }
        .to change(Commitment, :count).by(-1)
      expect(response).to redirect_to(company_path(company))
    end

    it 'cannot delete other members' do
      alice

      expect { delete commitment_path(Commitment.between(alice, company)) }
        .not_to change(Commitment, :count)
      expect(response).to redirect_to(company_path(company))
    end
  end

  context 'with a non-member, invited user' do
    before(:each) { sign_in carol }

    it 'diverts from the index' do
      get company_commitments_path(company)
      expect(response).to redirect_to(company_path(company))
    end

    it 'does not create a duplicate commitment' do
      expect do
        post company_commitments_path(company),
             params: { commitment: { user_id: carol.id } }
      end.not_to change(Commitment, :count)

      expect(response).to redirect_to(company_path(company))
    end

    it 'confirms invitation to join company' do
      expect do
        patch commitment_path(Commitment.between(carol, company)),
              params: { commitment: { user_id: carol.id,
                                      pending_member_conf: false } }
      end.to change { Commitment.between(carol, company).confirmed? }.from(false).to(true)

      expect(response).to redirect_to(company_path(company))
    end

    it 'cancels invitation to join company' do
      expect { delete commitment_path(Commitment.between(carol, company)) }
        .to change(Commitment, :count).by(-1)

      expect(response).to redirect_to(company_path(company))
    end

    it 'diverts from adding other users to company' do
      expect do
        post company_commitments_path(company),
             params: { commitment: { user_id: eve.id } }
      end.not_to change(Commitment, :count)

      expect(response).to redirect_to(company_path(company))
    end

    it 'diverts from admin-level changes' do
      bob

      expect do
        patch commitment_path(Commitment.between(bob, company)),
              params: { commitment: { admin: true } }
      end.not_to change { Commitment.between(bob, company).admin? }.from(false)

      expect(response).to redirect_to(company_path(company))
    end

    it 'diverts from deleting other users’ memberships' do
      bob

      expect do
        delete commitment_path(Commitment.between(bob, company))
      end.not_to change(Commitment, :count)

      expect(response).to redirect_to(company_path(company))
    end
  end

  context 'with a non-member, requested user' do
    before(:each) { sign_in david }

    it 'diverts from the index' do
      get company_commitments_path(company)
      expect(response).to redirect_to(company_path(company))
    end

    it 'does nothing if already has open request' do
      expect do
        post company_commitments_path(company),
             params: { commitment: { user_id: david.id } }
      end.not_to change(Commitment, :count)

      expect(response).to redirect_to(company_path(company))
    end

    it 'cancels request to join company' do
      expect { delete commitment_path(Commitment.between(david, company)) }
        .to change(Commitment, :count).by(-1)

      expect(response).to redirect_to(company_path(company))
    end
  end

  context 'with a non-member user' do
    before(:each) { sign_in eve }

    it 'diverts from modifying other users’ memberships' do
      company.add_member(david, pending: :member)
      expect do
        patch commitment_path(Commitment.between(david, company)),
              params: { commitment: { pending_member_conf: false } }
      end.not_to change { Commitment.between(david, company).confirmed? }.from(false)

      expect(response).to redirect_to(company_path(company))
    end

    it 'initiates request to join company' do
      expect do
        post company_commitments_path(company),
             params: { commitment: { user_id: eve.id } }
      end.to change(Commitment, :count).by(1)

      expect(Commitment.between(eve, company).confirmed?).to be(false)
      expect(response).to redirect_to(company_path(company))
    end
  end
end
