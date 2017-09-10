class SupplyLinks::PurchasersController < SupplyLinksController
  before_action :set_vars
  before_action :authenticate_user!
  before_action :authorize_action

  private
    def set_vars
      @company = supplier
      @supply_link = SupplyLink.find_by(id: params[:id]) if params.key?(:id)
    end

    def authorize_action
      unless current_user.is_admin?(supplier)
        redirect_to company_path(supplier) and return
      end
    end

    def supply_link_params
      { supplier: supplier, purchaser: purchaser, pending_supplier_conf: false }
        .tap do |p|
        if current_user.is_admin?(purchaser)
          p.merge!({ pending_purchaser_conf: false }) 
        end
      end
    end

    def supplier
      @supplier ||= @supply_link ?
        @supply_link.supplier : Company.find_by(id: params.dig(:company_id))
    end

    def purchaser
      @purchaser ||= @supply_link ?
        @supply_link.supplier : Company.find_by(id: params.dig(:purchaser, :id))
    end
end
