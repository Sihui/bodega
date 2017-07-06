class CreateCommitments < ActiveRecord::Migration[5.1]
  def change
    create_table :commitments do |t|
      t.belongs_to :user,           null: false, index: true
      t.belongs_to :company,        null: false, index: true
      t.string :role,               null: false, default: ''

      t.timestamps
    end
  end
end
