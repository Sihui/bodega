class Order < ApplicationRecord
  after_touch :update_total
  belongs_to :supplier,    class_name: :Company
  belongs_to :purchaser,   class_name: :Company
  belongs_to :placed_by,   class_name: :User
  belongs_to :accepted_by, class_name: :User, optional: true
  has_many :line_items,    dependent: :destroy
  accepts_nested_attributes_for :line_items

  validates :discount, numericality: { only_integer: true }, allow_nil: true
  validates :discount_type, inclusion: { in: %w(fixed percentage) }, allow_nil: true
  validate :meta_associations

  before_save :submission_init,
    if: -> (order) { order.changes[:submitted] == [false, true] }

  def self.search(_, filters)
    sql = []
    params = {}

    if filters.keys.include?("with")
      sql << "(supplier_id = :supplier_id)"

      params[:supplier_id] = (filters["with"] =~ /^\d+$/) ?
        filters["with"] : Company.search(filters["with"]).first.id
    end

    if filters.keys.include?("from")
      sql << "(purchaser_id = :purchaser_id)"

      params[:purchaser_id] = (filters["from"] =~ /^\d+$/) ?
        filters["from"] : Company.search(filters["from"]).first.id
    end

    if filters.keys.include?("placed_by")
      sql << "(placed_by_id = :placed_by_id)"

      params[:placed_by_id] = 
        if filters["placed_by"] =~ /^\d+$/
          filters["placed_by"]
        else
          filters = params.keys.include?("purchaser_id") ?
            { as: :member, of: Company.find_by(id: params[:purchaser_id]) } : {}
          User.search(filters["placed_by"], filters).first.id
        end
    end

    if filters.keys.include?("submitted")
      sql << "(submitted = :submitted)"

      params[:submitted] = (filters["submitted"].to_s == "true")
    end

    where(sql.join(" AND "), params)
  end

  def update_total
    reload
    subtotal = line_items.map(&:line_total).compact.reduce(&:+)
    total    = apply_discount(subtotal)
    update(total: total)
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

    def submission_init
      generate_invoice
      assign_attributes(created_at: DateTime.now)
    end
end
