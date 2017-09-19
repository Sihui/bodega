class Companies::SearchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_results

  def show
  end

  def create
    case @companies.count
    when 0
      render :no_results, locals: { query: search_params[:q] }
    when 1
      redirect_to @companies.first
    else
      redirect_to companies_search_path(search_params.reject { |_, v| v.blank? })
    end
  end

  private

    def set_results
      @companies = search_params[:id].present? ?
        Company.where("id = ?", search_params[:id]) :
        Company.search(search_params[:q], search_params[:filters])
    end

    def search_params
      params.permit(:id, :q, :filters).reverse_merge(filters: {})
    end
end
