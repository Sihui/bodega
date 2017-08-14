class Order < ApplicationRecord
  before_create :generate_invoice
  after_save :update_total
  belongs_to :supplier,    class_name: :Company
  belongs_to :purchaser,   class_name: :Company
  belongs_to :placed_by,   class_name: :User
  belongs_to :accepted_by, class_name: :User, optional: true
  has_many :line_items,    dependent: :destroy
  accepts_nested_attributes_for :line_items

  validates :discount, numericality: { only_integer: true }, allow_nil: true
  validates :discount_type, inclusion: { in: %w(fixed percentage) }, allow_nil: true
  validate :meta_associations

  def update_total
    subtotal = line_items.map(&:line_total).compact.reduce(&:+)
    total    = apply_discount(subtotal)
    update_column(:total, total)
  end

  def confirmed?
    !!accepted_by
  end

  def disputed?
    line_items.map(&:qty_disputed).any?
  end

  # Convenience method for creating LineItems.
  # Accepts both ActiveRecord objects and primary key IDs.
  def add(item, qty)
    item = Item.find_by(id: item) unless item.is_a?(Item)
    LineItem.create(order: self, item: item, qty: qty)
  end

  # Convenience method for updating quantities of LineItems.
  # Accepts both ActiveRecord objects and primary key IDs.
  def adjust(item, qty)
    item = Item.find_by(id: item) unless item.is_a?(Item)
    item.update(qty: qty) if line_items.include?(item)
  end

  private

    def generate_invoice
      self.invoice_no = next_invoice
    end

    def apply_discount(subtotal)
      return subtotal unless (discount && discount_type)

      case discount_type
      when 'percentage'
        subtotal * ((100.0 - discount) / 100)
      when 'fixed'
        subtotal - discount
      end
    end

    def next_invoice
      last_invoice ? last_invoice.next : first_invoice
    end

    def last_invoice
      @last_invoice ||= Order.where(supplier: supplier, purchaser: purchaser).order(:created_at).last&.invoice_no
    end

    def first_invoice
      "#{supplier.code}-#{purchaser.code}-00001"
    end

    def meta_associations
      errors.add(:supplier, "must be a confirmed supplier of #{purchaser}") \
        unless SupplyLink.for(supplier: supplier, purchaser: purchaser)&.confirmed?
      errors.add(:placed_by, 'must be a member of order purchaser') \
        unless placed_by&.belongs_to?(purchaser)
      errors.add(:accepted_by, 'must be a member of order supplier') \
        unless accepted_by.nil? || accepted_by.belongs_to?(supplier)
    end
end