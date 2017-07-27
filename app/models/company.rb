class Company < ApplicationRecord
  validates :name, presence: :true
  has_many :purchasers, through: :supply_links
  has_many :suppliers, through: :supply_links
  before_destroy :destroy_dependent_supply_links
  has_many :commitments, dependent: :destroy
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

  private

    def destroy_dependent_supply_links
      SupplyLink.where('supplier_id = ? OR purchaser_id = ?', id, id).each(&:destroy)
    end
end
