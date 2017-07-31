FactoryGirl.define do
  factory :company, aliases: [:supplier, :purchaser] do
    name { Faker::Company.name }
    code do
      name.split('').reject { |ltr| %w(a e i o u y \ ).include?(ltr) }
        .take(4).join.upcase if name
    end
    str_addr { Faker::Address.street_address }
    city { Faker::Address.city }

    transient do
      supplier  nil
      purchaser nil
      pending   :none
    end

    before(:create) do |company, e|
      e.supplier.add_purchaser(company, pending: e.pending) if e.supplier
      e.purchaser.add_supplier(company, pending: e.pending) if e.purchaser
    end
  end
end
