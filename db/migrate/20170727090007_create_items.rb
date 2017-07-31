class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.string :name,        null: false
      t.string :ref_code
      t.integer :price,      null: false
      t.string :unit_size,   null: false
      t.belongs_to :company, foreign_key: true

      t.timestamps
    end

    add_index :items, [:name, :company_id],     unique: true
    add_index :items, [:ref_code, :company_id], unique: true
  end
end
