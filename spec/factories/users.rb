FactoryGirl.define do
  factory :user do
    name  { Faker::Name.name }

    transient do
      from    nil            # a company (or array of companies) to be added to
      admin   false
      pending :none
    end

    after(:build) do |user, e|
      if e.from
        companies =* e.from  # coerce e.from to Array
        companies.each do |c|
          c.add_member(user, admin: e.admin, pending: e.pending)
        end
      end
    end

    trait :registered do
      after(:create) do |user, e|
        create(:account, user: user)
      end
    end
  end
end
