require 'rails_helper'

# Routes -----------------------------------------------------------------------
#    companies GET    /companies(.:format)          companies#index
#              POST   /companies(.:format)          companies#create
#  new_company GET    /companies/new(.:format)      companies#new
# edit_company GET    /companies/:id/edit(.:format) companies#edit
#      company GET    /companies/:id(.:format)      companies#show
#              DELETE /companies/:id(.:format)      companies#destroy
#              PATCH  /companies/:id(.:format)      companies#update

describe 'Companies Endpoints', type: :request do
  let :co_name { Faker::Company.name }

  context 'with anonymous user' do
    it 'always redirects to sign-in page' do
      post companies_path
      expect(response).to redirect_to(new_user_session_path)

      get new_company_path
      expect(response).to redirect_to(new_user_session_path)

      get edit_company_path(acme)
      expect(response).to redirect_to(new_user_session_path)

      get company_path(acme)
      expect(response).to redirect_to(new_user_session_path)

      delete company_path(acme)
      expect(response).to redirect_to(new_user_session_path)

      patch company_path(acme)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'as Company admin' do
    before(:each) { sign_in alice }

    it 'shows “Edit” form' do
      get edit_company_path(acme)
      expect(response.body).to have_xpath("//form[@action='#{company_path}']"\
                                                "[@method='post']")
    end

    it 'deletes Company' do
      acme                    # create(:company)
      expect { delete company_path(acme) }.to change(Company, :count).by(-1)
      expect(response).to redirect_to(user_registration_path)
    end

    it 'updates Company' do
      patch company_path(acme), params: { company: { name: co_name } }
      acme.reload             # reload object state from DB
      expect(acme.name).to eq(co_name)
      expect(response).to redirect_to(company_path(acme))
    end
  end

  context 'as Company member' do
    before(:each) { sign_in arthur }

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
      patch company_path(acme), params: { company: { name: co_name } }
      acme.reload             # reload object state from DB
      expect(acme.name).not_to eq(co_name)
      expect(response).to redirect_to(company_path(acme))
    end
  end

  context 'with unaffiliated user' do
    before(:each) { sign_in zack }

    it 'creates Company' do
      expect { post companies_path,
               params: { company: { name: co_name, code: 'ABCD' } } }
        .to change(Company, :count).by(1)
      expect(Company.find_by(name: co_name).admin?(zack)).to be(true)
      expect(response).to redirect_to(company_path(Company.find_by(name: co_name)))
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
      patch company_path(acme), params: { company: { name: co_name } }
      acme.reload             # reload object state from DB
      expect(acme.name).not_to eq(co_name)
      expect(response).to redirect_to(company_path(acme))
    end
  end
end
