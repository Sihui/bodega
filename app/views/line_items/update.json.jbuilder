if @line_item.changes.none?
  order = @line_item.order.reload
  json.rerender([{ replace: "$('#cart')",
                   with: render(partial: "line_items/order_form",
                                object: order,
                                as: :order),
                   needsListeners: true },
                 { replace: "$('#total > strong')",
                   with: "#{order.total}元" }])
else
  json.flash({ alert: "#{@line_item.item.name} #{@line_item.errors.messages[:item].join(' / ')}"})
end
