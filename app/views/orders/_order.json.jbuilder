json.extract! order, :id, :supplier_id, :purchaser_id, :invoice, :created_at, :updated_at
json.url order_url(order, format: :json)
