if @company.changes.none?
  json.flash({ notice: "#{@company.name} was successfully updated." })
  json.rerender([{ replace: "that.rendered",
                   with: render(partial: 'details',
                                object: @company,
                                as: :company) },
                 { replace: "$('#nav__companies')",
                   with: render(partial: 'companies/li',
                                collection: current_user.confirmed_companies,
                                as: :company) }])
  json.form_fields(@company.as_json(except: [:id, :created_at, :updated_at]))
else
  json.flash({ alert: "#{@company.name} could not be updated." })
  json.errors @company.errors
end
