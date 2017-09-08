if @commitment.persisted?
  json.flash({ notice: "Your request has been submitted and is pending admin approval." })
  json.status(@commitment.confirmed? ? :joined : :pending)
  json.rerender([{ replace: "$('#company_request_index')",
                   with: render("companies/company_request_index") },
                 { replace: "$('#join_company').children('form')",
                   with: "Membership request pending" }])
else
  json.flash({ alert: "Your request could not be processed." })
  json.errors @commitment.errors
end
