FactoryGirl.define do
  factory :account do
    user
    email { Faker::Internet.email }
    password 'password'
  end
end
