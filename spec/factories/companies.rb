FactoryGirl.define do
  factory :company, aliases: [:supplier, :purchaser] do
    # BASE =====================================================================
    name { memoed_name }
    sequence :code do |n|
      n.to_s + memoed_name.split('').reject { |c| c =~ /\W/ }.take(6 - n.to_s.length).join
    end
    str_addr { Faker::Address.street_address }
    city { Faker::Address.city }

    # VARIANTS =================================================================
    transient do
      # make sure `code` dependent attribute doesn't break when testing `name: nil`
      memoed_name { Faker::Company.name }
      supplier   nil
      purchaser  nil
      pending    :none
      size       5
    end

    # Specify supplier/puchaser ------------------------------------------------
    before(:create) do |company, e|
      e.supplier.add_purchaser(company, pending: e.pending) if e.supplier
      e.purchaser.add_supplier(company, pending: e.pending) if e.purchaser
    end

    # Spawn inventory ----------------------------------------------------------
    trait :with_inventory do
      after(:create) do |company, e|
        create_list(:item, e.size, supplier: company)
      end
    end
  end
end
