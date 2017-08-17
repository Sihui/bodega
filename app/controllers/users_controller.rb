class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
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
      @user = User.find_by(id: params[:id]) if params.key?(:id)
    end

    def user_params
    end
end
