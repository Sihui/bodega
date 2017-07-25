class CommitmentsController < ApplicationController
  before_action :set_commitment, only: [:update, :destroy]
  before_action :set_company
  before_action :authenticate_user!

  def index
    redirect_to company_path(@company) and return unless current_user.belongs_to?(@company)
    @commitments = Commitment.where(company_id: params[:company_id])
  end

  def create
    @commitment = Commitment.new(commitment_params)
    redirect_to company_path(@company) and return unless authorized_user?

    respond_to do |format|
      if @commitment.save
        format.html { redirect_to @company, notice: 'Commitment was successfully created.' }
        format.json { render :show, status: :created, location: @commitment }
      else
        format.html { redirect_to @company, alert: 'Commitment failed to be created.' }
        format.json { render json: @commitment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    redirect_to company_path(@company) and return unless authorized_user?
    respond_to do |format|
      if @commitment.update_attributes(commitment_params)
        format.html { redirect_to @company, notice: 'Commitment was successfully updated.' }
        format.json { render :show, status: :created, location: @commitment }
      else
        format.html { render :new }
        format.json { render json: @commitment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    redirect_to company_path(@company) and return unless authorized_user?
    @commitment.destroy
    respond_to do |format|
      format.html { redirect_to company_path(@company), notice: 'Commitment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_company
      @company = params[:company_id] ? Company.find(params[:company_id]) : @commitment.company
    end

    def set_commitment
      @commitment = Commitment.find(params[:id])
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

    def authorized_user?
      current_user.is_admin?(@company) || current_user_is_target?
    end
    
    def current_user_is_target?
      current_user == (Commitment.find_by(id: params[:id])&.user ||
        User.find_by(id: params.dig(:commitment, :user_id)))
    end
end
