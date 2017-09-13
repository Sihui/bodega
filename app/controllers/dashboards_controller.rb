class DashboardsController < ApplicationController
  def show
    render "pages/home" unless user_signed_in?
  end
end
