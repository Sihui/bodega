class Company < ApplicationRecord
  validates :name, uniqueness: true, presence: true
  validates :code, uniqueness: true,
                   format: { with:    /\A\w{3,6}\Z/,
                             message: "must be 3–6 letters/numbers"}
  before_save :format_code
  has_many :purchaser_links, class_name:  :SupplyLink,
                             foreign_key: :supplier_id,
                             dependent:   :destroy
  has_many :supplier_links,  class_name:  :SupplyLink,
                             foreign_key: :purchaser_id,
                             dependent:   :destroy
  has_many :purchasers, through: :purchaser_links
  has_many :suppliers,  through: :supplier_links
  has_many :commitments, dependent: :destroy
  has_many :items, foreign_key: :supplier_id
  has_many :users, through: :commitments
  accepts_nested_attributes_for :commitments

  # before_save :generate_code

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

  private

  def format_code
    self.code.upcase!
  end

  #   def generate_code
  #     # TODO: repeat until unique
  #     # TODO: employ alternate strategy to ensure code is 4 chars long
  #     self.code ||= name.upcase.split('')
  #                       .reject { |char| char !~ /[^\WAEIOUY]/ }
  #                       .take(4).join
  #   end
end
