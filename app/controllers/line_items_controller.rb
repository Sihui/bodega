class LineItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_line_item
  before_action :authorize_user

  def create
    @line_item.assign_attributes(new_line_item_params)

    if @line_item.save
      render status: :created
    else
      render status: :unprocessable_entity
    end
  end

  def update
    @line_item.update(edit_line_item_params)
  end

  def destroy
  end

  private
    def set_line_item
      @line_item = LineItem.find_by(id: params[:id]) ||
        LineItem.new(order: Order.find_by(id: params[:order_id]))
    end

    def authorize_user
      purchaser = @line_item.order.purchaser
      redirect_to root_path unless current_user.belongs_to?(purchaser)
    end

    def new_line_item_params
      params.require(:line_item).permit(:item_id, :qty).tap do |p|
        item_name = params.dig(:line_item, :item_name)
        if (p[:item_id].blank? && item_name.present?)
          item_supplier = @line_item.order.supplier
          item_id = Item.search(item_name, { from: item_supplier }).first.id
          p.merge!({ item_id: item_id } )
        end
      end
    end

    def edit_line_item_params
      params.require(:line_item).permit(:qty)
    end
end
