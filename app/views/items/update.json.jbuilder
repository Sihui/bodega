if @item.changes.none?
  json.flash({ notice: "#{@item.name} was successfully updated." })
  json.rerender({ replace: "that.rendered",
                  with: render(partial: 'details', object: @item, as: :item) })
  json.form_fields(@item.as_json(except: [:id, :created_at, :updated_at]))
else
  json.flash({ alert: "#{@item.name} could not be updated." })
  json.errors @item.errors
end
