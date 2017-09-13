if @order.persisted?
  json.id @order.id
  json.supplier @order.supplier.name
  json.purchaser @order.purchaser.name
else
end
