class Item < ApplicationRecord
  belongs_to :supplier, class_name: :Company
  validates :name, uniqueness: { scope: :supplier_id }
  validates :ref_code, uniqueness: { scope: :supplier_id }, allow_nil: true
end
