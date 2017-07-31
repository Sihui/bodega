class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.string     :name,       null: false
      t.string     :ref_code
      t.integer    :price,      null: false
      t.string     :unit_size,  null: false
      t.belongs_to :supplier,   null: false,
                                foreign_key: { to_table: :companies }

      t.timestamps
    end

    add_index :items, [:name, :supplier_id],     unique: true
    add_index :items, [:ref_code, :supplier_id], unique: true
  end
end
