class CreateCommitments < ActiveRecord::Migration[5.1]
  def change
    create_table :commitments do |t|
      t.belongs_to :user,           null: false, index: true
      t.belongs_to :company,        null: false, index: true
      t.boolean    :admin,          null: false, default: false

      t.timestamps
    end
  end
end
