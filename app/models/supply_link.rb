class SupplyLink < ApplicationRecord
  include Confirmable

  belongs_to :purchaser, class_name: :Company
  belongs_to :supplier,  class_name: :Company
  validates :purchaser_id, uniqueness: { scope: :supplier_id }
  validates :pending_purchaser_conf, inclusion: { in: [true, false] }
  validates :pending_supplier_conf,  inclusion: { in: [true, false] }

  def self.between(a, b)
    find_by(supplier: a, purchaser: b) || find_by(supplier: b, purchaser: a)
  end
end
