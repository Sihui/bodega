class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method [:current_user, :user_signed_in?]

  def current_user
    current_account.user
  end

  def user_signed_in?
    account_signed_in?
  end

  def authenticate_user!
    authenticate_account!
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:email, :password, :password_confirmation,
                         { user_attributes: [:name] })
    end
  end

end
