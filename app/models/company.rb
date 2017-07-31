class Company < ApplicationRecord
  validates :name, presence: :true, uniqueness: true
  validates :code, allow_nil: true
  has_many :purchaser_links, class_name:  :SupplyLink,
                             foreign_key: :supplier_id,
                             dependent:   :destroy
  has_many :supplier_links,  class_name:  :SupplyLink,
                             foreign_key: :purchaser_id,
                             dependent:   :destroy
  has_many :purchasers, through: :purchaser_links
  has_many :suppliers,  through: :supplier_links
  has_many :commitments, dependent: :destroy
  has_many :users, through: :commitments
  has_many :items, foreign_key: :supplier_id

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

  def supply_links
    purchaser_links + supplier_links
  end
end
