Project
================================================================================

## RIGHT NOW

1. Convert company-index to a vue component
2. USE PROPS

## UI/UX

### View: root

### Partial: Nav menu

### View: users/show

* /user
  * User info
  * Index of affiliated companies
    * Staff preview
    * Supply links
    * Inventory size
    * Outstanding orders

#### What should happen when I click the button?

1. DONE The button should deactivate
2. The endpoint should be hit
   * DONE What response should it give?
3. Upon success,
   * DONE a flash message should be rendered
   * DONE the company-index should be reloaded (data retrieved by AJAX)
   * DONE the form should be reset
4. On failure,
   * DONE a flash message should be rendered
   * DONE the button should reactivate

### View: company/(:id)

## Reevaluate design

* TODO invoice number formatting rules
* TODO referential integrity, e.g., for when a user wants to remove an
       item which was referenced in previous orders (and is thus blocked)

### Orders

Have a status: open, modified (pending confirmation), confirmed, delivered, flagged (for review)

* define cascading **tiers** of users to be notified of pending orders

|         | purchaser        | supplier                                        |
| ------- | ---------------- | ----------------------------------------------- |
| create  | yes (record who) | no                                              |
| read    | yes              | yes                                             |
| update  | update/dispute   | confirm/apply-discount/downsize/resolve-dispute |
| destroy | cancel           | no                                              |

#### Database Tables

1. Orders
   * `supplier`
   * `purchaser`
   * `placed_by`
   * `accepted_by`
   * `invoice_no`
   * `discount`
   * `discount_type`
   * `notes`
2. LineItems
   * `order`
   * `item`
   * `qty`
   * `price`
   * `total`
   * `comped`
   * `qty_disputed`

## API

### Static

* `GET    /home(.:format)                redirect(301, /)`
  * [Override High Voltage controller][hv]
    * TODO shows landing page if no `current_user`
    * TODO shows dashboard if logged in

## Look up later

  * Routes: duplicate URLs with `as: ''`?

Meta-Work
================================================================================

## TODO UML Diagrams

### Resources

  * https://www.simple-talk.com/sql/sql-tools/automatically-creating-uml-database-diagrams-for-sql-server/
  * http://www.agiledata.org/essays/umlDataModelingProfile.html
  * http://zbz5.net/sequence-diagrams-vim-and-plantuml
  * http://agilemodeling.com/artifacts/crcModel.htm
  * http://agilemodeling.com/artifacts/classDiagram.htm

---

[hv]: https://github.com/thoughtbot/high_voltage#override
