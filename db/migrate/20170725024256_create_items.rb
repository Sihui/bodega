class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.string :name,        null: false, index: true
      t.string :ref_code
      t.integer :price,      null: false
      t.string :unit_size,   null: false
      t.belongs_to :company, foreign_key: true
    end
  end
end
