FactoryGirl.define do
  factory :user do
    name  { Faker::Name.name }
    email { Faker::Internet.email }
    password 'password'

    transient do
      company nil
      admin   false
      pending :none
    end

    before(:create) do |user, e|
      if e.company
        companies =* e.company  # coerce e.company to Array
        companies.each do |c|
          c.add_member(user, admin: e.admin, pending: e.pending)
        end
      end
    end
  end
end
