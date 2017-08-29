class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def local_request?(ref)

    regex = /https?:\/\/[a-zA-Z\d-]*.[a-zA-Z\d-]*.[a-zA-Z]+/
    regex.match(ref).to_s == request.env['HTTP_ORIGIN'].to_s

  end

  private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |user_params| user_params.permit(:email, :password, :password_confirmation, :first_name, :last_name) }
    devise_parameter_sanitizer.permit(:account_update) { |user_params| user_params.permit(:email, :password, :password_confirmation, :current_password, :first_name, :last_name) }
    devise_parameter_sanitizer.permit(:accept_invitation) { |user_params| user_params.permit(:email, :password, :password_confirmation, :invitation_token, :first_name, :last_name)}
  end

end
