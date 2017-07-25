class CreateCommitments < ActiveRecord::Migration[5.1]
  def change
    create_table :commitments do |t|
      t.belongs_to :user,                null: false, index: true, foreign_key: true
      t.belongs_to :company,             null: false, index: true, foreign_key: true
      t.boolean    :admin,               null: false, default: false
      t.boolean    :pending_admin_conf,  null: false, default: true
      t.boolean    :pending_member_conf, null: false, default: true

      t.timestamps
    end

    add_index :commitments, [:user_id, :company_id], unique: true
  end
end
