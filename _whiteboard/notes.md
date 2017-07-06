ONBOARDING PROCESS
------------------

1. sign up
   * enter email & password
   * receive confirmation email
   * visit confirmation link
2. set up account
   * register a company (user automatically becomes company OWNER)
     * specify company ROLE (supplier/purchaser)
   * or join a company (checks not blacklisted, requires authorization from company ADMIN)
3. Invite company members
   * provide email address
   * specify member ROLE (admin/manager/buyer/seller/???)
   * so-and-so receives invite email (bypass confirmation)
4. Approve company members
   * receive notification email
   * visit link
   * select role & approve
   * or ignore
   * or deny (blacklist)
5. Build profiles
   * users & companies can add/edit profile photos
6. Connect companies
   * Dashboard features separate "Add suppliers" and "Add purchasers" links (visibility depends on company's selected roles)
   * Adding company prompts confirmation/authorization with company admin
7. Suppliers' inventories
   * edit access limited to owner/admin/managers
   * upload via csv
   * modify multiple records in bulk

DATABASE SCHEMA
---------------

### Tables

* Devise User (HABTM companies through c-u, has-one photo as profile)
  * email
  * display name
  * login credentials
* Company (HABTM users through c-u, has many products, self-join suppliers to purchasers, has-one photo as profile)
  * display name
  * supplier?
  * purchaser?
* Photo (belongs-to profile)
  * data
  * profile
  * profile-type
* Company-User (validate user/company combination is unique)
  * User ID
  * User role
  * Company ID
* Company-Company ("supply link", validate both fields unique)
  * supplier ID (validate company.supplier?)
  * purchaser ID (validate company.purchaser?)
* Products (belongs to a company, validate company.supplier?)
