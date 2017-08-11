FactoryGirl.define do
  factory :order do
    supplier
    purchaser
    placed_by { build(:user, from: purchaser) }

    before(:create) do |order, e|
      order.supplier.add_purchaser(order.purchaser, pending: :none)
      order.placed_by&.save
    end

    trait(:populated) do
      association :supplier, :with_inventory
      line_items_attributes do
        create_list(:item, 5, supplier: supplier) if supplier.items.count < 5
        (1..5).map { |n| attributes_for(:line_item, item_id: n) }
      end
    end
  end
end
