FactoryGirl.define do
  factory :item do
    sequence(:name) { |n| n.to_s + Faker::Food.dish }
    ref_code do
      name.split('').reject { |ltr| %w(a e i o u y \ ).include?(ltr) }
        .take(4).join.upcase
    end
    price { (rand(40) + 20) * 10 }
    unit_size { Faker::Food.measurement }
    supplier
  end
end
