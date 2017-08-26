class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index

    @user = User.find(current_user.id) if current_user
  end
end
