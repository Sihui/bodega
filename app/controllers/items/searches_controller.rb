class Items::SearchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_results

  def create
    render :no_results, locals: { query: search_params[:q] } unless @item
  end

  private

    def set_results
      @item = search_params[:id].present? ?
        Item.find_by(id: search_params[:id]) :
        Item.search(search_params[:q], search_params[:filters]).first
    end

    def search_params
      params.permit(:id, :q).merge({ filters: { from: params[:company_id] } })
    end
end
