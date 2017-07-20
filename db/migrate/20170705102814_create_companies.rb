class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name,               index: { unique: true }, null: false
      t.string :code,               index: { unique: true }
      t.string :str_addr
      t.string :city

      t.timestamps
    end

    create_table :supply_link, id: false do |t|
      t.belongs_to :supplier,       null: false, index: true
      t.belongs_to :purchaser,      null: false, index: true
    end
  end
end
