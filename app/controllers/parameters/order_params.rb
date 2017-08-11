class OrderParams < ActionController::Parameters
  def initialize(params = {})
    params = params.permit(params.keys).to_h if params.respond_to?(:permitted?)
    super params
    @order = Order.find_by(id: params[:id]) if params.key?(:id)
    convert_line_items
  end

  def for_creation_by(user)
    permit(:supplier_id, :purchaser_id, :notes,
           line_items_attributes: [:order_id, :item_id, :qty])
      .merge({ placed_by: user })
  end

  def for_amending_by(user)
    return unless user.belongs_to?(@order.purchaser) && !@order.confirmed?
    permit(line_items_attributes: [:id, :qty])
  end

  def for_disputing_by(user)
    return unless user.belongs_to?(@order.purchaser) && @order.confirmed?
    permit(line_items_attributes: [:id, :qty_disputed])
  end

  def for_accepting_by(user)
    return unless user.belongs_to?(@order.supplier) && !@order.confirmed?
    permit.merge({ accepted_by: user })
  end

  def for_discounting_by(user)
    return unless user.belongs_to?(@order.supplier)
    permit(:discount, :discount_type, line_item_attributes: [:id, :comped])
      .merge({ accepted_by: user })
  end

  def for_downsizing_by(user)
    return unless user.belongs_to?(@order.supplier)
    fetch(:line_items_attributes)&.select! do |attr|
      attr[:qty] < LineItem.where(id: attr[:id]).pluck(:qty).first
    end

    permit(line_items_attributes: [:id, :qty]).merge({ accepted_by: user })
  end

  def for_resolving_by(user)
    return unless user.belongs_to?(@order.supplier) && @order.confirmed?

    fetch(:line_items_attributes)&.select! do |attr|
      attr[:qty] == LineItem.where(id: attr[:id]).pluck(:qty_disputed).first
    end

    permit(line_items_attributes: [:id, :qty])
  end

  private

    def convert_line_items
      if fetch(:line_items_attributes, nil)&.is_a?(String)
        self[:line_items_attributes] = YAML.load(fetch(:line_items_attributes))
      end
    end
end
