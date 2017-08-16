class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  
  private
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |user_params| user_params.permit(:email, :password, :password_confirmation, :first_name, :last_name) }
    devise_parameter_sanitizer.permit(:account_update) { |user_params| user_params.permit(:email, :password, :password_confirmation, :current_password, :first_name, :last_name) }
  end
  
end
