require 'rails_helper'

# Routes -----------------------------------------------------------------------
# GET    /companies/:company_id/commitments(.:format) commitments#index
# POST   /companies/:company_id/commitments(.:format) commitments#create
# PATCH  /commitments/:id(.:format)                   commitments#update
# PUT    /commitments/:id(.:format)                   commitments#update
# DELETE /commitments/:id(.:format)                   commitments#destroy

describe 'Commitments Endpoints', type: :request do
  context 'with anonymous user' do
    it 'always redirects to sign-in page' do
      get company_commitments_path(acme)
      expect(response).to redirect_to(new_user_session_path)

      post company_commitments_path(acme)
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
      arthur

      get company_commitments_path(acme)
      expect(response.body).to have_xpath("//a[@href='#{user_path(alice)}']")
      expect(response.body).to have_xpath("//a[@href='#{user_path(arthur)}']")
    end

    it 'adds new members (pending confirmation)' do
      expect do
        post company_commitments_path(acme),
             params: { commitment: { user_id: zack.id } }
      end.to change(Commitment, :count).by(1)
      expect(Commitment.between(zack, acme).confirmed?).to be(false)

      expect(response).to redirect_to(company_path(acme))
    end

    it 'cannot confirm member invitations' do
      expect do
        patch commitment_path(Commitment.between(andrew, acme)),
              params: { commitment: { pending_member_conf: false } }
      end.not_to change { Commitment.between(andrew, acme).confirmed? }.from(false)

      expect(response).to redirect_to(company_path(acme))
    end

    it 'updates existing members' do
      expect do
        patch commitment_path(Commitment.between(arthur, acme)),
          params: { commitment: { admin: true } }
      end.to change { Commitment.between(arthur, acme).admin? }.to(true)
      expect(response).to redirect_to(company_path(acme))
    end

    it 'deletes other members' do
      arthur

      expect { delete commitment_path(Commitment.between(arthur, acme)) }
        .to change(Commitment, :count).by(-1)
      expect(response).to redirect_to(company_path(acme))
    end
  end

  context 'with a non-admin user' do
    before(:each) { sign_in arthur }

    it 'shows index' do
      alice

      get company_commitments_path(acme)
      expect(response.body).to have_xpath("//a[@href='#{user_path(alice)}']")
      expect(response.body).to have_xpath("//a[@href='#{user_path(arthur)}']")
    end

    it 'cannot add new members' do
      expect do
        post company_commitments_path(acme),
             params: { commitment: { user_id: zack.id } }
      end.not_to change(Commitment, :count)

      expect(response).to redirect_to(company_path(acme))
    end

    it 'cannot update existing members' do
      expect do
        patch commitment_path(Commitment.between(arthur, acme)),
          params: { commitment: { admin: true } }
      end.not_to change { Commitment.between(arthur, acme).admin? }.from(false)
      expect(response).to redirect_to(company_path(acme))
    end

    it 'deletes self' do
      expect { delete commitment_path(Commitment.between(arthur, acme)) }
        .to change(Commitment, :count).by(-1)
      expect(response).to redirect_to(company_path(acme))
    end

    it 'cannot delete other members' do
      alice

      expect { delete commitment_path(Commitment.between(alice, acme)) }
        .not_to change(Commitment, :count)
      expect(response).to redirect_to(company_path(acme))
    end
  end

  context 'with a non-member, invited user' do
    before(:each) { sign_in andrew }

    it 'diverts from the index' do
      get company_commitments_path(acme)
      expect(response).to redirect_to(company_path(acme))
    end

    it 'does not create a duplicate commitment' do
      expect do
        post company_commitments_path(acme),
             params: { commitment: { user_id: andrew.id } }
      end.not_to change(Commitment, :count)

      expect(response).to redirect_to(company_path(acme))
    end

    it 'confirms invitation to join company' do
      expect do
        patch commitment_path(Commitment.between(andrew, acme)),
              params: { commitment: { user_id: andrew.id,
                                      pending_member_conf: false } }
      end.to change { Commitment.between(andrew, acme).confirmed? }.to(true)

      expect(response).to redirect_to(company_path(acme))
    end

    it 'cancels invitation to join company' do
      expect { delete commitment_path(Commitment.between(andrew, acme)) }
        .to change(Commitment, :count).by(-1)

      expect(response).to redirect_to(company_path(acme))
    end

    it 'diverts from adding other users to company' do
      expect do
        post company_commitments_path(acme),
             params: { commitment: { user_id: zack.id } }
      end.not_to change(Commitment, :count)

      expect(response).to redirect_to(company_path(acme))
    end

    it 'diverts from admin-lzackl changes' do
      arthur

      expect do
        patch commitment_path(Commitment.between(arthur, acme)),
              params: { commitment: { admin: true } }
      end.not_to change { Commitment.between(arthur, acme).admin? }.from(false)

      expect(response).to redirect_to(company_path(acme))
    end

    it 'diverts from deleting other users’ memberships' do
      arthur

      expect do
        delete commitment_path(Commitment.between(arthur, acme))
      end.not_to change(Commitment, :count)

      expect(response).to redirect_to(company_path(acme))
    end
  end

  context 'with a non-member, requested user' do
    before(:each) { sign_in amelia }

    it 'diverts from the index' do
      get company_commitments_path(acme)
      expect(response).to redirect_to(company_path(acme))
    end

    it 'does nothing if already has open request' do
      expect do
        post company_commitments_path(acme),
             params: { commitment: { user_id: amelia.id } }
      end.not_to change(Commitment, :count)

      expect(response).to redirect_to(company_path(acme))
    end

    it 'cancels request to join company' do
      expect { delete commitment_path(Commitment.between(amelia, acme)) }
        .to change(Commitment, :count).by(-1)

      expect(response).to redirect_to(company_path(acme))
    end
  end

  context 'with a non-member user' do
    before(:each) { sign_in zack }

    it 'diverts from modifying other users’ memberships' do
      acme.add_member(amelia, pending: :member)
      expect do
        patch commitment_path(Commitment.between(amelia, acme)),
              params: { commitment: { pending_member_conf: false } }
      end.not_to change { Commitment.between(amelia, acme).confirmed? }.from(false)

      expect(response).to redirect_to(company_path(acme))
    end

    it 'initiates request to join company' do
      expect do
        post company_commitments_path(acme),
             params: { commitment: { user_id: zack.id } }
      end.to change(Commitment, :count).by(1)

      expect(Commitment.between(zack, acme).confirmed?).to be(false)
      expect(response).to redirect_to(company_path(acme))
    end
  end
end
