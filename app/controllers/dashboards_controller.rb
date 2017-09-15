class DashboardsController < ApplicationController
  def show
    @user = current_user if user_signed_in?
    render @user ? "users/show" : "pages/home"
  end
end
