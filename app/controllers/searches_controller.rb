class SearchesController < ApplicationController
  before_action :authenticate_user!

  def create
    @search = search_params.to_h
    @search[:model] = Object.const_get(@search[:model].capitalize)

    if model_valid?
      @search[:results] = @search[:model].search(@search[:query], @search[:filters])
      render status: :ok
    else
      render status: :unprocessable_entity
    end
  end

  private
    def search_params
      params.require(:search).permit(:model, :query, filters: [:of, :as, :from, :for])
        .tap { |p| p.reverse_merge!(filters: {}) }
    end

    def model_valid?
      defined?(@search[:model]) && @search[:model].respond_to?(:model_name)
    end
end
