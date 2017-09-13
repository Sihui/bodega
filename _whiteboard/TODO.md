Project
================================================================================

## RIGHT NOW

* add “cancel” buttons to confirmation dialogs for memberships and supply links
* add “admin” checkbox for adding new members
* add delete buttons for various resources (where should they go?)

## UP NEXT

* clean up partials (move to appropriate folders)
* place orders
  user: selects company
  page: hides company select, displays item search + empty order form

  user: searches for item name, selects from autocomplete
  page: resets item seach form, prepends item entry to order form

  user: clicks "remove" on item in order form
  page: removes item

  user: submits order
  page: accepts order, displays confirmation, notifies supplier

  In raw HTML, we have an order form with separate fields each representing a single OrderItem...

## LATER

* rename `Company#users` to `Company#members`
* Routes: duplicate URLs with `as: ''`?
* [Override High Voltage controller][hv]
  * TODO shows landing page if no `current_user`
  * TODO shows dashboard if logged in
* implement garber-irish DOM-ready javascript

### Reevaluate design

* TODO company code validation rules
* TODO invoice number formatting rules
* TODO referential integrity, e.g., for when a user wants to remove an
       item which was referenced in previous orders (and is thus blocked)

### Orders Schema

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
