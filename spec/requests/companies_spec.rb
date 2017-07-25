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
  let :user { create(:user) }
  let :company { create(:company) }
  let :co_name { Faker::Company.name }

  context 'with anonymous user' do
    it 'always redirects to sign-in page' do
      post companies_path
      expect(response).to redirect_to(new_user_session_path)

      get new_company_path
      expect(response).to redirect_to(new_user_session_path)

      get edit_company_path(company)
      expect(response).to redirect_to(new_user_session_path)

      get company_path(company)
      expect(response).to redirect_to(new_user_session_path)

      delete company_path(company)
      expect(response).to redirect_to(new_user_session_path)

      patch company_path(company)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with valid user' do
    before(:each) { sign_in user }

    it 'creates Company' do
      expect { post companies_path, params: { company: { name: co_name } } }
        .to change(Company, :count).by(1)
      expect(Company.find_by(name: co_name).admin?(user)).to be(true)
      expect(response).to redirect_to(company_path(Company.find_by(name: co_name)))
    end

    it 'shows "New" form' do
      get new_company_path
      expect(response.body).to have_xpath("//form[@action='#{companies_path}']"\
                                                "[@method='post']")
    end

    it 'shows profile' do
      get company_path(company)
      expect(response.body).to include(CGI.escape_html(company.name))
    end

    context 'as Company admin' do
      before { company.add_member(user, admin: true) }

      it 'shows "Edit" form' do
        get edit_company_path(company)
        expect(response.body).to have_xpath("//form[@action='#{company_path}']"\
                                                  "[@method='post']")
      end

      it 'deletes Company' do
        company                    # create company via `let` statement
        expect { delete company_path(company) }.to change(Company, :count).by(-1)
        expect(response).to redirect_to(user_registration_path)
      end

      it 'updates Company' do
        patch company_path(company), params: { company: { name: co_name } }
        company.reload             # reload object state from DB
        expect(company.name).to eq(co_name)
        expect(response).to redirect_to(company_path(company))
      end
    end

    context 'as Company member' do
      before { company.add_member(user) }

      it 'diverts from "Edit" form' do
        get edit_company_path(company)
        expect(response).to redirect_to(company_path(company))
      end

      it 'diverts from deletion' do
        company                    # create company via `let` statement
        expect { delete company_path(company) }.not_to change(Company, :count)
        expect(response).to redirect_to(company_path(company))
      end

      it 'diverts from updates' do
        patch company_path(company), params: { company: { name: co_name} }
        company.reload             # reload object state from DB
        expect(company.name).not_to eq(co_name)
        expect(response).to redirect_to(company_path(company))
      end
    end

    context 'with no Company affiliation' do
      it 'diverts from "Edit" form' do
        get edit_company_path(company)
        expect(response).to redirect_to(company_path(company))
      end

      it 'diverts from deletion' do
        company                    # create company via `let` statement
        expect { delete company_path(company) }.not_to change(Company, :count)
        expect(response).to redirect_to(company_path(company))
      end

      it 'diverts from updates' do
        patch company_path(company), params: { company: { name: co_name} }
        company.reload             # reload object state from DB
        expect(company.name).not_to eq(co_name)
        expect(response).to redirect_to(company_path(company))
      end
    end
  end
end
