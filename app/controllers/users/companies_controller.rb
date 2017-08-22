class Users::CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def create
    respond_to do |format|
      company = Company.new(company_params)

      if @user.save_company(company)
        format.html { redirect_to @user, notice: 'Company was successfully created.' }
        format.json { render json: @user.companies, status: :created }
      else
        format.html { render :new }
        format.json { render json: company.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_user
      @user = current_user
    end

    def company_params
      params.require(:company).permit(:name, :code, :str_addr, :city)
    end
end
