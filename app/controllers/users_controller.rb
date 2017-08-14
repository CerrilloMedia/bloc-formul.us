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
    @connections = current_user.connections
    
    @formulas = case
                when current_user.is_self?(@user)
                  if @user.client?
                    # guests can see their whole history
                    @user.formulas.first(10)
                  else
                    # artists would see their complete client history
                    @user.guest_formulas.first(10)
                  end
                when current_user.client? && @user.artist?
                  # when a client visists an artists page, should only return their own client history with specific artist.
                  @user.guest_formulas.where('client_id = ?', current_user.id)
                when current_user.artist? && @user.client?
                  # when artist visits any client page it shows clients entire general history
                  @user.formulas
                when current_user.artist? && @user.artist?
                  @user.guest_formulas
                end
                
    @formula = @formulas.first
    
  end
  
  def edit
    @user = User.find(current_user.id)
  end
  
end
