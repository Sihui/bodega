class User < ApplicationRecord
  validates :name, presence: true
  has_one :account, dependent: :destroy
  accepts_nested_attributes_for :account, allow_destroy: true
  delegate :email, to: :account

  has_many :commitments
  has_many :companies, through: :commitments

  def save_company(company)
    company.save && company.add_member(self, admin: true)
  end

  def belongs_to?(company)
    companies.include?(company) && Commitment.between(self, company).confirmed?
  end

  def is_admin?(company)
    commitments.any? { |c| c.company == company && c.admin }
  end

  def is_purchaser?(company)
    (company.purchasers & companies).any?
  end
end
