class Company < ApplicationRecord
  has_and_belongs_to_many :providers, join_table: :supply_link,
                                      class_name: :Company,
                                      foreign_key: :supplier_id,
                                      association_foreign_key: :provider_id
  has_and_belongs_to_many :suppliers, join_table: :supply_link,
                                      class_name: :Company,
                                      foreign_key: :provider_id,
                                      association_foreign_key: :supplier_id

  has_many :commitments
  has_many :users, through: :commitments
end
