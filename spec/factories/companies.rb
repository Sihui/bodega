FactoryGirl.define do
  factory :company, aliases: [:supplier, :purchaser] do
    name { Faker::Company.name }
    code { Faker::Internet.user_name }
    str_addr { Faker::Address.street_address }
    city { Faker::Address.city }
  end
end
