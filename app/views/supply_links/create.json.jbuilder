their_role = controller_name.gsub(/s$/, '').to_sym
them       = @supply_link.send(their_role)

if @supply_link.persisted?
  if @supply_link.confirmed?
    notice   = "#{them.name} has been added to your #{their_role}s."
    rerender = { append: render(partial: 'companies/snippet',
                                object: them,
                                as: :company),
                 to: "$('##{their_role}_index')" }
  else
    notice   = "Your request has been submitted."
    rerender = { replace: "$('#pending_#{their_role}_summary')",
                 with: render(partial: "companies/supply_links_pending",
                              locals: { their_role: their_role }) }
  end
  json.flash({ notice: notice })
  json.rerender(rerender)
else
  json.flash({ alert: "Your request could not be processed." })
end
