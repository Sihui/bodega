class Company < ApplicationRecord
  validates :name, presence: :true
  has_and_belongs_to_many :purchasers, through: :supply_links
  has_and_belongs_to_many :suppliers, through: :supply_links
  has_many :commitments
  has_many :users, through: :commitments

  def admin?(user)
    commitments.any? { |c| (c.user == user) && (c.admin) }
  end

  def member?(user)
    users.include?(user)
  end

  def add_member(user, admin: false, pending: :none)
    commitments.create(user: user, admin: admin).confirm!(pending: pending)
  end

  def add_supplier(supplier, pending: :supplier)
    SupplyLink.create(supplier: supplier, purchaser: self)
      .confirm!(pending: pending)
  end

  def add_purchaser(purchaser, pending: :purchaser)
    SupplyLink.create(supplier: self, purchaser: purchaser)
      .confirm!(pending: pending)
  end
end
