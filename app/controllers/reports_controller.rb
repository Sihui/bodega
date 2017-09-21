class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vars
  before_action :authorize_user

  def show
    @range = date_range
    @orders = orders
    @total = @orders.map(&:total).reduce(:+)
  end

  private
    def set_vars
      @supply_link = SupplyLink.find_by(id: params[:supply_link_id])
    end

    def authorize_user
      unless current_user.belongs_to?(@supply_link.purchaser) ||
        current_user.belongs_to?(@supply_link.supplier)
        redirect_to root_path 
      end
    end

    def report_params
      params.permit(:start_date, :end_date)
    end

    def date_range
      # reformat keys & values ({ start: <Date>, end: <Date> })
      range = Hash[report_params.to_h.map do |k, v|
        [k.to_s.gsub(/_date$/, "").to_sym, v.to_date] 
      end]
      
      # swap dates if in wrong order
      range.tap do |h|
        h[:start], h[:end] = h[:end], h[:start] if h[:start] > h[:end]
      end
    end

    def orders
      sql = []
      sql_params = {}

      sql << "accepted_by_id <> NULL"

      sql << "supplier_id = :supplier_id"
      sql_params[:supplier_id] = @supply_link.supplier.id

      sql << "purchaser_id = :purchaser_id"
      sql_params[:purchaser_id] = @supply_link.purchaser.id

      sql << "created_at > :start_date"
      sql_params[:start_date] = @range[:start]

      sql << "created_at < :end_date"
      sql_params[:end_date] = @range[:end].next

      Order.where(sql.join(" AND "), sql_params).order("created_at desc")
    end
end
