class CommitmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vars
  before_action :authorize_action, except: :index

  def index
    redirect_to company_path(@company) and return unless current_user.belongs_to?(@company)
    @commitments = Commitment.where(company_id: params[:company_id])
  end

  def create
    @commitment = Commitment.new(commitment_params)

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
    @commitment.destroy
    respond_to do |format|
      format.html { redirect_to company_path(@company), notice: 'Commitment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_vars
      @commitment = Commitment.find(params[:id]) if params.key?(:id)
      @company = @commitment&.company || Company.find(params[:company_id])
    end

    def authorize_action
      unless current_user.is_admin?(@company) || current_user_is_target?
        redirect_to company_path(@company) and return 
      end
    end

    def current_user_is_target?
      current_user == (Commitment.find_by(id: params[:id])&.user ||
        User.find_by(id: params.dig(:commitment, :user_id)))
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
