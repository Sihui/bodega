if @company.persisted?
  json.flash({ notice: "#{@company.name} was created successfully." })
  json.snippet(render partial: 'companies/snippet', object: @company, as: :company)
  json.li(render partial: 'companies/li', object: @company, as: :company)
else
  subject = @company.name.blank? ? "Company" : @company.name
  json.flash({ alert: "#{subject} could not be saved." })
  json.errors @company.errors
end
