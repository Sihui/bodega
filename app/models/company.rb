class Company < ApplicationRecord
  validates :name, presence: :true
  has_and_belongs_to_many :purchasers, -> { distinct },
                                       join_table: :supply_link,
                                       class_name: :Company,
                                       foreign_key: :supplier_id,
                                       association_foreign_key: :purchaser_id
  has_and_belongs_to_many :suppliers, -> { distinct },
                                      join_table: :supply_link,
                                      class_name: :Company,
                                      foreign_key: :purchaser_id,
                                      association_foreign_key: :supplier_id

  has_many :commitments
  has_many :users, through: :commitments

  def admin?(user)
    commitments.any? { |c| (c.user == user) && (c.admin) }
  end
end
