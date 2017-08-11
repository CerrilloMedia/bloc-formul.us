class UsersController < ApplicationController
  before_action :authenticate_user!
  
  def index
        @users = if current_user
                    
                    if current_user.artist?
                        User.client
                    elsif current_user.admin?
                        User.all
                    else
                        User.artist
                    end
                 else
                    #public view of artists
                    User.artist
                 end
                 
        @connections = current_user.connections
  end
  
  def show
    @user = User.find(params[:id])
    unless @user == current_user
      @connections = current_user.connections
    else
      @connections = []
    end
    @formulas = @user.formulas.order('id DESC').first(6)
    @formula = @formulas.first || nil
    
  end
  
  def edit
    @user = User.find(current_user.id)
  end
  
end
