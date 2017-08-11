class LineItem < ApplicationRecord
  before_save :calculate_line_total
  after_save :update_total
  after_save :clear_resolved_dispute
  after_save :destroy_if_empty
  belongs_to :order
  belongs_to :item
  validates :qty,          numericality: { only_integer: true }
  validates :qty_disputed, numericality: { only_integer: true }, allow_nil: true

  def comp!
    self.comped = true
    save!
  end

  private

    def calculate_line_total
      self.price      = item.price
      self.line_total = comped? ? 0 : (price * qty)
    end

    def update_total
      order.update_total
    end

    def clear_resolved_dispute
      update_column(:qty_disputed, nil) if qty == qty_disputed
    end

    def destroy_if_empty
      destroy if qty < 1
    end
end
