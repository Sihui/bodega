class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name,               index: { unique: true }, null: false
      t.string :code,               index: { unique: true }
      t.string :str_addr
      t.string :city

      t.timestamps
    end

    create_table :supply_links do |t|
      t.belongs_to :supplier,  null: false, index: true, foreign_key: true
      t.belongs_to :purchaser, null: false, index: true, foreign_key: true
      t.boolean    :pending_supplier_conf,  null: false, default: true
      t.boolean    :pending_purchaser_conf, null: false, default: true
    end
  end
end
