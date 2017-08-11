class CreateLineItems < ActiveRecord::Migration[5.1]
  def change
    create_table :line_items do |t|
      t.belongs_to :order,      null: false, foreign_key: true, index: true
      t.belongs_to :item,       null: false, foreign_key: true
      t.integer    :qty,        null: false, default: 1
      t.integer    :price,      null: false
      t.integer    :line_total, null: false

      t.boolean    :comped,     null: false, default: false
      t.integer    :qty_disputed

      t.timestamps
    end
  end
end
