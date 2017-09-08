their_role = controller_name.gsub(/s$/, '').to_sym

if @supply_link.changes.none?
  json.flash({ notice: "#{@supply_link.supplier.name} has been added to #{@supply_link.purchaser.name.gsub(/('s)?$/, "'s")} suppliers." })
  json.rerender([{ replace: "$('##{their_role}_request_count')",
                   with: render(partial: "companies/supply_links_request_count",
                                locals: { their_role: their_role }) },
                 { append: render(partial: "companies/snippet",
                                  object: @supply_link.send(their_role),
                                  as: :company),
                   to: "$('##{their_role}_index')" },
                 { remove: "$(\".#{their_role}_request_form > " \
                           "form[action$='/#{@supply_link.id}']\").parent()" }])
else
  json.flash({ alert: "Supply link could not be updated." })
end
