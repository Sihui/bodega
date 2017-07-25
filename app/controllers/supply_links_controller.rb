class SupplyLinksController < ApplicationController
  before_action :set_supply_link, only: [:update, :destroy]
  before_action :authenticate_user!

  def create
  end

  def update
  end

  def destroy
  end

  private

    def set_supply_link
      @supply_link = SupplyLink.find(params[:id])
    end

    def commitment_params
      params.require(:commitment).permit(:user_id)
        .merge(params.permit(:company_id))
        .tap do |p|
          p.merge!(params[:commitment].permit(:admin, :pending_admin_conf)) \
            if current_user.is_admin?(@company)
          p.merge!(params[:commitment].permit(:pending_member_conf)) \
            if current_user_is_target?
        end
    end
end
