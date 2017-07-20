FactoryGirl.define do
  factory :company, aliases: [:supplier, :purchaser] do
    name { Faker::Company.name }
    code { Faker::Internet.user_name }
    str_addr { Faker::Address.street_address }
    city { Faker::Address.city }

    trait :with_supplier do
      after(:create) do |company, evaluator|
        create(:supplier, purchasers: [company])
      end
    end

    trait :with_purchaser do
      after(:create) do |company, evaluator|
        create(:purchaser, suppliers: [company])
      end
    end
  end
end
