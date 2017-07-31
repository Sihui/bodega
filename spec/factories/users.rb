FactoryGirl.define do
  factory :user do
    name  { Faker::Name.name }
    email { Faker::Internet.email }
    password 'password'

    transient do
      from    nil
      admin   false
      pending :none
    end

    before(:create) do |user, e|
      if e.from
        companies =* e.from  # coerce e.from to Array
        companies.each do |c|
          c.add_member(user, admin: e.admin, pending: e.pending)
        end
      end
    end
  end
end
