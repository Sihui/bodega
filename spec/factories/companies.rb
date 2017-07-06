FactoryGirl.define do
  factory :company do
    name { Faker::Company.name }
    code 'abc'
    str_addr { Faker::Address.street_address }
    city { Faker::Address.city }

    association :supplier, factory: :company
    association :provider, factory: :company
  end
end
