Project
================================================================================

## Layout

### `application.html.slim`

* TODO include header with navigation links

## API

### Static

* `GET    /home(.:format)                redirect(301, /)`
  * [Override High Voltage controller][hv]
    * TODO shows landing page if no `current_user`
    * TODO shows dashboard if logged in

### Companies

* `GET    /companies(.:format)          companies#index`
  * TODO shows a listing of companies
* `POST   /companies(.:format)          companies#create`
  * TODO creates company record
  * TODO creates owner-level commitment from `current_user`
  * TODO redirects to ???
* `GET    /companies/new(.:format)      companies#new`
  * TODO shows new company form
* `GET    /companies/:id/edit(.:format) companies#edit`
  * TODO shows edit company form
* `GET    /companies/:id(.:format)      companies#show`
  * TODO shows company profile
* `PATCH  /companies/:id(.:format)      companies#update`
  * TODO updates company record
  * TODO redirects to ???
* `DELETE /companies/:id(.:format)      companies#destroy`
  * TODO destroys company record
  * TODO redirects to ???

### Users

* `GET    /sign_in(.:format)             devise/sessions#new`
* `POST   /sign_in(.:format)             devise/sessions#create`
* `DELETE /sign_out(.:format)            devise/sessions#destroy`
* `GET    /reset_password(.:format)      devise/passwords#new`
* `POST   /reset_password(.:format)      devise/passwords#create`
* `GET    /sign_up(.:format)             devise/registrations#new`
* `GET    /user/edit(.:format)           devise/registrations#edit`
* `GET    /user(.:format)                devise/registrations#show`
* `PATCH  /user(.:format)                devise/registrations#update`
* `DELETE /user(.:format)                devise/registrations#destroy`
* `POST   /user(.:format)                devise/registrations#create`

### Commitments

What is the procedure?

* User logs in
* goes to company page
* clicks “add members”
* searches for members (by name or email)
* selects a user, then confirms
* hits API endpoint: commitments#create
* creates unconfirmed commitment with auth-pending user ID
* notifies user of request (via email and in dashboard)
* user hits API endpoint: commitments#confirm
* commitment is created/activated

API endpoint needs to know: `company`, `member`, `admin?`, `member_confirmed?`, `admin_confirmed?`

* `GET    /companies/:id/members(.:format)      commitments#index`
* `POST   /companies/:id/members(.:format)      commitments#create`
* `PATCH  /companies/:id/members/:id(.:format)  commitments#update`
* `DELETE /companies/:id/members/:id(.:format)  commitments#destroy`

## Look up later

  * Routes: duplicate URLs with `as: ''`?

Meta-Work
================================================================================

## UML Diagrams

  * TODO decide how important it is...

### Resources

  * https://www.simple-talk.com/sql/sql-tools/automatically-creating-uml-database-diagrams-for-sql-server/
  * http://www.agiledata.org/essays/umlDataModelingProfile.html
  * http://zbz5.net/sequence-diagrams-vim-and-plantuml
  * http://agilemodeling.com/artifacts/crcModel.htm
  * http://agilemodeling.com/artifacts/classDiagram.htm

---

[hv]: https://github.com/thoughtbot/high_voltage#override

