case @search[:results].first
when Company
  json.array!(@search[:results]) do |company|
    json.label("#{company.name} (#{company.code})")
    json.value(company.name)
    json.id(company.id)
  end
when User
  json.array!(@search[:results]) do |user|
    json.label(user.name)
    json.value(user.name)
    json.id(user.id)
  end
when Item
  json.array!(@search[:results]) do |item|
    json.label("#{item.name} (#{item.price}元/#{item.unit_size})")
    json.value(item.name)
    json.id(item.id)
  end
end
