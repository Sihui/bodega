@company ||= @commitment.company
@user ||= @commitment.user

if @commitment.destroyed?
  json.flash({ notice: "The membership request was successfully denied." })
  json.rerender([{ replace: "$('#membership_request_count')",
                   with: render("companies/membership_request_count") },
                 { replace: "$('#company_request_count')",
                   with: render("users/company_request_count") },
                 { remove: "$(\".membership_request_form > " \
                           "form[action$='/#{@commitment.id}']\").parent()" },
                 { remove: "$(\".company_request_form > " \
                           "form[action$='/#{@commitment.id}']\").parent()" }])
else
  json.flash({ alert: "The membership request could not be deleted." })
end
