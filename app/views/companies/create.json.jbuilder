if @company.persisted?
  json.flash({ notice: "#{@company.name} was created successfully." })
  if (@company.users.count == 1) && (@company.users.first.companies.count == 1)
    json.rerender([{ replace: "that.rendered",
                     with: render(partial: 'companies/snippet',
                                  object: @company,
                                  as: :company) },
                   { append: render(partial: 'companies/li',
                                    object: @company,
                                    as: :company),
                     to: "$('#nav__user_companies')" }])
  else
    json.rerender([{ append: render(partial: 'companies/snippet',
                                    object: @company,
                                    as: :company),
                     to: "that.rendered" },
                   { append: render(partial: 'companies/li',
                                    object: @company,
                                    as: :company),
                     to: "$('#nav__user_companies')" }])
  end
else
  name = @company.name.blank? ? "Company" : @company.name
  json.flash({ alert: "#{name} could not be saved." })
  json.errors @company.errors
end
