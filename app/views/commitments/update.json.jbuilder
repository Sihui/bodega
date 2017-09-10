@company ||= @commitment.company
@user ||= @commitment.user

if @commitment.changes.none?
  json.flash({ notice: "#{@commitment.user.name} is now a member of #{@commitment.company.name}." })
  json.rerender([{ replace: "$('#membership_request_count')",
                   with: render("companies/membership_request_count") },
                 { append: render(partial: "companies/member_snippet",
                                  object: @user,
                                  as: :member),
                   to: "$('#member_index')" },
                 { remove: "$(\".membership_request_form > " \
                           "form[action$='/#{@commitment.id}']\").parent()" },
                 { replace: "$('#company_request_count')",
                   with: render("users/company_request_count") },
                 { replace: "$('#company_index')",
                   with: render(partial: "users/company_index") },
                 { remove: "$(\".company_request_form > " \
                           "form[action$='/#{@commitment.id}']\").parent()" }])
else
  json.flash({ alert: "#{@commitment.user.name} could not be added to #{@commitment.company.name}." })
end
