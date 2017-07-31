FactoryGirl.define do
  factory :company, aliases: [:supplier, :purchaser] do
    name { Faker::Company.name }
    code do
      name.split('').reject { |ltr| %w(a e i o u y \ ).include?(ltr) }
        .take(4).join.upcase
    end
    str_addr { Faker::Address.street_address }
    city { Faker::Address.city }
  end
end
