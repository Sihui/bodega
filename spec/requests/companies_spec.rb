require 'rails_helper'

# Routes -----------------------------------------------------------------------
#    companies GET    /companies(.:format)          companies#index
#              POST   /companies(.:format)          companies#create
#  new_company GET    /companies/new(.:format)      companies#new
# edit_company GET    /companies/:id/edit(.:format) companies#edit
#      company GET    /companies/:id(.:format)      companies#show
#              DELETE /companies/:id(.:format)      companies#destroy
#              PATCH  /companies/:id(.:format)      companies#update

RSpec.describe 'Companies Endpoints', type: :request do
  let :attributes { attributes_for(:company) }

  context 'with anonymous user' do
    it 'always redirects to sign-in page' do
      post companies_path
      expect(response).to redirect_to(new_account_session_path)

      get new_company_path
      expect(response).to redirect_to(new_account_session_path)

      get edit_company_path(acme)
      expect(response).to redirect_to(new_account_session_path)

      get company_path(acme)
      expect(response).to redirect_to(new_account_session_path)

      delete company_path(acme)
      expect(response).to redirect_to(new_account_session_path)

      patch company_path(acme)
      expect(response).to redirect_to(new_account_session_path)
    end
  end

  context 'as Company admin' do
    before(:each) { sign_in alice.account }

    it 'shows “Edit” form' do
      get edit_company_path(acme)
      expect(response.body).to have_xpath("//form[@action='#{company_path}']"\
                                                "[@method='post']")
    end

    it 'deletes Company' do
      acme                    # create(:company)
      expect { delete company_path(acme) }.to change(Company, :count).by(-1)
      expect(response).to redirect_to(account_registration_path)
    end

    it 'updates Company' do
      expect do
        patch company_path(acme), params: { company: attributes }
      end.to change { acme.reload.name }.to(attributes[:name])
      expect(response).to redirect_to(company_path(acme))
    end
  end

  context 'as Company member' do
    before(:each) { sign_in arthur.account }

    it 'diverts from “Edit” form' do
      get edit_company_path(acme)
      expect(response).to redirect_to(company_path(acme))
    end

    it 'diverts from deletion' do
      acme                    # create(:company)
      expect { delete company_path(acme) }.not_to change(Company, :count)
      expect(response).to redirect_to(company_path(acme))
    end

    it 'diverts from updates' do
      expect do
        patch company_path(acme), params: { company: attributes }
      end.not_to change { acme.reload.name }
      expect(response).to redirect_to(company_path(acme))
    end
  end

  context 'with unaffiliated user' do
    before(:each) { sign_in zack.account }

    it 'creates Company' do
      expect { post companies_path,
               params: { company: attributes.slice(:name, :code) } }
        .to change(Company, :count).by(1)
      expect(Company.find_by(name: attributes[:name])).to eq(Company.last)
      expect(Company.last.admin?(zack)).to be(true)
      expect(response).to redirect_to(Company.last)
    end

    it 'shows “New” form' do
      get new_company_path
      expect(response.body).to have_xpath("//form[@action='#{companies_path}']"\
                                                "[@method='post']")
    end

    it 'shows profile' do
      get company_path(acme)
      expect(response.body).to include(CGI.escape_html(acme.name))
    end

    it 'diverts from “Edit” form' do
      get edit_company_path(acme)
      expect(response).to redirect_to(company_path(acme))
    end

    it 'diverts from deletion' do
      acme                    # create(:company)
      expect { delete company_path(acme) }.not_to change(Company, :count)
      expect(response).to redirect_to(company_path(acme))
    end

    it 'diverts from updates' do
      expect do
        patch company_path(acme), params: { company: attributes }
      end.not_to change { acme.reload.name }
      expect(response).to redirect_to(company_path(acme))
    end
  end
end
