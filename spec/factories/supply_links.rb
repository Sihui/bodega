FactoryGirl.define do
  factory :supply_link do
    supplier
    purchaser
    pending_supplier_conf true
    pending_purchaser_conf true
  end
end
