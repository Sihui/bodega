class Commitment < ApplicationRecord
  cattr_reader :confirmers, instance_reader: false do [:admin, :member] end
  include Confirmable

  validates :user_id, uniqueness: { scope: :company_id }
  belongs_to :user
  belongs_to :company

  def self.between(a, b)
    find_by(user: a, company: b) || find_by(user: b, company: a)
  end
end
