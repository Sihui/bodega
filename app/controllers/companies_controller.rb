class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @companies = Company.all
  end

  def show
  end

  def new
    @company = Company.new
  end

  # responds ONLY with JSON
  def create
    @company = Company.new(company_params)

    render status: current_user.save_company(@company) ? :created : :unprocessable_entity
  end

  def update
    redirect_to @company and return unless @company.admin?(current_user)

    render status: @company.update(company_params) ? :ok : :unprocessable_entity
  end

  def destroy
    redirect_to @company and return unless @company.admin?(current_user)
    @company.destroy
    respond_to do |format|
      format.html { redirect_to account_registration_path, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_company
      @company ||= Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(:name, :code, :str_addr, :city)
    end
end
