FactoryGirl.define do
  factory :supply_link do
    association :supplier,  factory: :company
    association :purchaser, factory: :company
    pending_supplier_conf true
    pending_purchaser_conf true
  end
end
