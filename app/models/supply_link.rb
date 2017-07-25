class SupplyLink < ApplicationRecord
  include Confirmable
  cattr_reader :confirmers, instance_reader: false do [:purchaser, :supplier] end

  validates :purchaser_id, uniqueness: { scope: :company_id }
  belongs_to :purchaser, class_name: 'Company'
  belongs_to :supplier,  class_name: 'Company'

  def self.between(a, b)
    find_by(supplier: a, purchaser: b) || find_by(supplier: b, purchaser: a)
  end
end
