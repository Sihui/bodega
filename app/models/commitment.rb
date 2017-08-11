class Commitment < ApplicationRecord
  cattr_reader :confirmers, instance_reader: false do [:admin, :member] end
  include Confirmable

  belongs_to :user
  belongs_to :company
  validates :user_id, uniqueness: { scope: :company_id }
  validates :admin,               inclusion: { in: [true, false] }
  validates :pending_admin_conf,  inclusion: { in: [true, false] }
  validates :pending_member_conf, inclusion: { in: [true, false] }

  def self.between(a, b)
    find_by(user: a, company: b) || find_by(user: b, company: a)
  end
end
