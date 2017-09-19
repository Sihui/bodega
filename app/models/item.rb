class Item < ApplicationRecord
  belongs_to :supplier, class_name: :Company
  validates :name, uniqueness: { scope: :supplier_id }, presence: true
  validates :ref_code, uniqueness: { scope: :supplier_id }, allow_nil: true

  def self.search(query, filters)
    sql = ["(LOWER(name) LIKE :query OR LOWER(ref_code) LIKE :query)"]
    params = { query: "%#{query}%" }
    
    if filters.keys.include?("from")
      sql << "(supplier_id = :supplier_id)"

      params[:supplier_id] = (filters["from"] =~ /^\d+$/) ?
        filters["from"] : Company.search(filters["from"]).first.id
    end

    if filters.keys.include?("for")
      sql << "(id NOT IN (:added))"

      order = Order.find_by(id: filters["for"])
      params[:added] = order.line_items.map(&:item).map(&:id)
      params[:added] << 0 if params[:added].empty?
    end

    where(sql.join(" AND "), params)
  end
end
