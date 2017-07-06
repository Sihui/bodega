FactoryGirl.define do
  factory :commitment do |f|
    role :admin
    user
    company
  end
end
