class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name,               null: false, default: ""
      t.string :code
      t.string :str_addr
      t.string :city

      t.timestamps
    end

    add_index :companies, :name,   unique: true
    add_index :companies, :code,   unique: true

    create_table :supply_link, id: false do |t|
      t.belongs_to :supplier,       null: false, index: true
      t.belongs_to :provider,       null: false, index: true
    end
  end
end
