class SupplyLinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vars
  before_action :authorize_action

  def create
    @supply_link = SupplyLink.new(supply_link_params)

    render status: @supply_link.save ? :created : :unprocessable_entity
  end

  def update
    render status: @supply_link.update(supply_link_params) ? :ok : :unprocessable_entity
  end

  def destroy
    @supply_link.destroy
    respond_to do |format|
      format.html { redirect_to company_path(@company), notice: 'Supply Link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_vars
      @supply_link = SupplyLink.find(params[:id]) if params.key?(:id)
      @company     = Company.find(params[:company_id])
    end

    def authorize_action
      unless represented_roles.any? && represented_companies.include?(@company)
        redirect_to company_path(@company) and return
      end
    end

    def supply_link_params
      params.require(:supply_link).permit(:supplier_id, :purchaser_id)
        .tap do |p|
          represented_roles.each do |role|
            p.merge!(params[:supply_link].permit("pending_#{role}_conf"))
          end
        end
    end

    # returns an array of symbols, e.g. [:supplier, :purchaser]
    def represented_roles
      SupplyLink.confirmers.select { |role| current_user.is_admin?(send(role)) }
    end

    # returns an array of Company objects
    def represented_companies
      represented_roles.map { |role| send(role) }
    end

    def supplier
      @supply_link&.supplier || Company.find_by(id: params.dig(:supply_link, :supplier_id))
    end

    def purchaser
      @supply_link&.purchaser || Company.find_by(id: params.dig(:supply_link, :purchaser_id))
    end
end
