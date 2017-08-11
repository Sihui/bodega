Project
================================================================================

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

### Reports

## Layout

* TODO Learn Vue.js

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
