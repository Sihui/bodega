if @user.changes.none?
  json.flash({ notice: "#{@user.name} was successfully updated." })
  json.rerender({ replace: "that.rendered",
                  with: render(partial: "details", object: @user, as: :user) })
  json.form_fields(@user.as_json(except: [:id, :created_at, :updated_at]))
else
  name = @user.name.blank? ? "User" : @user.name
  json.flash({ alert: "#{name} could not be updated." })
  json.errors @user.errors
end
