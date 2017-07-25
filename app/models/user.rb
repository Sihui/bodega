class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true

  has_many :commitments
  has_many :companies, through: :commitments

  def belongs_to?(company)
    companies.include?(company) && Commitment.between(self, company).confirmed?
  end

  def is_admin?(company)
    commitments.any? { |c| c.company == company && c.admin }
  end
end
