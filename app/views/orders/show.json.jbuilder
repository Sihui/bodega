json.rerender([{ replace: "$('#cart')",
                 with: render(partial: "orders/form"),
                 needsListeners: true },
               { replace: "$('#total > strong')",
                 with: "#{@order.total}元" }])
