# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Users ------------------------------------------------------------------------
Account.create(email:           "andy.dwyer@gmail.com",
               password:        "password",
               user_attributes: { name: "Andy Dwyer" })

Account.create(email:           "bob.belcher@gmail.com",
               password:        "password",
               user_attributes: { name: "Bob Belcher" })

Account.create(email:           "charlie.day@gmail.com",
               password:        "password",
               user_attributes: { name: "Charlie Day" })

Account.create(email:           "homer.simpson@gmail.com",
               password:        "password",
               user_attributes: { name: "Homer Simpson" })

# Companies & Commitments ------------------------------------------------------
User.first.create_company(name: "Snakehole Lounge", code: "SNK", city: "Pawnee")
User.second.create_company(name: "Bob's Burgers", code: "BOB", city: "Longport")
User.third.create_company(name: "Paddy's Pub", code: "PDY", city: "Philadelphia")
User.fourth.create_company(name: "Krusty Burger", code: "KRST", city: "Springfield")

# Supply Links -----------------------------------------------------------------
Company.all.each.with_index do |c, i|
  c.add_supplier(Company.find(((i + 1) % 4) + 1), pending: :none)
  c.add_supplier(Company.find(((i + 2) % 4) + 1), pending: :none)
end

# Items ------------------------------------------------------------------------
[{ name: "snake juice", ref_code: "snkjc", price: "600", unit_size: "1000mL" },
 { name: "sour mix",    ref_code: "srmx",  price: "200", unit_size: "1000mL" },
 { name: "vermouth",    ref_code: "vrmth", price: "400", unit_size: "1000mL" },
 { name: "gin",         ref_code: "grdns", price: "600", unit_size: "1000mL" },
 { name: "vodka",       ref_code: "popov", price: "300", unit_size: "1000mL" }]
  .each do |i|
  Item.create(i.merge({ supplier: Company.first }))
end

[{ name: "ground beef", ref_code: "grdbf", price: "300", unit_size: "2kg" },
 { name: "buns",        ref_code: "bun",   price: "100", unit_size: "4ct" },
 { name: "feta cheese", ref_code: "ftchs", price: "300", unit_size: "500g" },
 { name: "cauliflower", ref_code: "clflr", price: "100", unit_size: "500g" },
 { name: "corn salsa",  ref_code: "cnsls", price: "300", unit_size: "500g" }]
  .each do |i|
  Item.create(i.merge({ supplier: Company.second }))
end

[{ name: "rum ham",    ref_code: "rham",   price: "1500", unit_size: "5kg" },
 { name: "riot juice", ref_code: "rjc",    price: "500",  unit_size: "4L" },
 { name: "milk steak", ref_code: "mlkstk", price: "200",  unit_size: "1kg" },
 { name: "fight milk", ref_code: "ftmlk",  price: "500",  unit_size: "5L" }]
  .each do |i|
  Item.create(i.merge({ supplier: Company.third }))
end

[{ name: "patties",    ref_code: "ptt",   price: "1000", unit_size: "40ct" },
 { name: "egg mix",    ref_code: "egg",   price: "600",  unit_size: "3L" },
 { name: "cheese",     ref_code: "amchs", price: "100",  unit_size: "100pc" },
 { name: "soda syrup", ref_code: "syrp",  price: "300",  unit_size: "5kg" },
 { name: "fries",      ref_code: "frs",   price: "200",  unit_size: "5kg" }]
  .each do |i|
  Item.create(i.merge({ supplier: Company.fourth }))
end

