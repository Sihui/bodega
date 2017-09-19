@company = @item.supplier
if @item.persisted?
  json.flash({ notice: "#{@item.name} was created successfully." })
  json.rerender([{ append: render(partial: 'items/snippet',
                                  object: @item,
                                  as: :item),
                   to: "that.rendered",
                   needsListeners: true },
                 { replace: "$('#inventory_size')",
                   with: render('companies/item_count') }])
  json.form_fields(@item.as_json(except: [:id, :created_at, :updated_at]))
else
  subject = @item.name.blank? ? "item" : @item.name
  json.flash({ alert: "#{subject} could not be saved." })
  json.errors @item.errors
end
