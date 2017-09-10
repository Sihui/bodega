class User < ApplicationRecord
  validates :name, presence: true
  has_one :account, dependent: :destroy
  accepts_nested_attributes_for :account, allow_destroy: true
  delegate :email, to: :account

  has_many :commitments
  has_many :companies, through: :commitments

  def self.search(query, filters = {})
    results = where('LOWER(name) LIKE ?', "%#{query}%")

    if (filters.keys & %w(of as)).length == 2
      company = Company.find_by(name: filters['of'])

      if filters.dig('as') == 'new_member'
        filter  = company.users.pluck(:id)
        results = results.where('id NOT IN (?)', filter)
      end
    end
  end

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

  def confirmed_companies
    commitments.select(&:confirmed?).map(&:company)
  end

  def unconfirmed_companies
    commitments.reject(&:confirmed?).map(&:company)
  end

  def requests_pending_self
    commitments.select(&:pending_member_conf?)
  end

  def requests_pending_company
    commitments.select(&:pending_admin_conf?)
  end
end
