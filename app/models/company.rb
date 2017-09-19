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
  has_many :items, foreign_key: :supplier_id, dependent: :destroy
  has_many :users, through: :commitments
  accepts_nested_attributes_for :commitments

  def self.search(query, filters = {})
    sql = ["(LOWER(name) LIKE :query OR LOWER(code) LIKE :query)"]
    params = { query: "%#{query}%" }

    if (filters.keys & %w(of as)).length == 2
      sql << "(id IS NOT :us) AND (id NOT IN (:them))"

      us = find_by(name: filters["of"])
      case filters["as"]
      when "new_supplier"
        params[:them] = us.suppliers.pluck(:id)
      when "new_purchaser"
        params[:them] = us.purchasers.pluck(:id)
      end

      params[:us] = us.id
      params[:them] << 0 if params[:them].empty?
    end

    where(sql.join(" AND "), params)
  end

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

  def confirmed_members
    commitments.select(&:confirmed?).map(&:user)
  end

  def unconfirmed_members
    commitments.reject(&:confirmed?).map(&:user)
  end

  def requests_pending_member
    commitments.select(&:pending_member_conf?)
  end

  def requests_pending_admin
    commitments.select(&:pending_admin_conf?)
  end

  def confirmed_purchasers
    purchaser_links.select(&:confirmed?).map(&:purchaser)
  end

  def confirmed_suppliers
    supplier_links.select(&:confirmed?).map(&:supplier)
  end

  def requests_from_purchasers
    purchaser_links.select(&:pending_supplier_conf?)
  end

  def requests_from_suppliers
    supplier_links.select(&:pending_purchaser_conf?)
  end

  def requests_to_purchasers
    purchaser_links.select(&:pending_purchaser_conf?)
  end

  def requests_to_suppliers
    supplier_links.select(&:pending_supplier_conf?)
  end

  private

  def format_code
    self.code.upcase!
  end
end
