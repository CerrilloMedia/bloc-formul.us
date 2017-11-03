class UsersController < ApplicationController
  before_action :authenticate_user!
  # include DeviseInvitable::Inviter

  def index

    @users =  if current_user.artist?
                  # client list
                  current_user.salon_users
              elsif current_user.client?
                  current_user.inverse_salon_users
              else
                  User.all # admin view
              end

    unless params[:search].nil? || params[:search].strip.empty?
      array = User.search(params[:search].strip)
      @users = array.flatten.delete_if { |i| i.id === current_user.id }
    end

    if params[:email] && @users.empty?
      current_user.invite_new(params[:email])
    end

  end

  def show

    @user = User.find(params[:id])

    unless current_user.artist? && @user.client? || current_user.connection_ids.include?(@user.id) || current_user.is_self?(@user)
      flash[:alert] = "You do can not access this profile. Consider connecting with them first"
      redirect_to request.referrer || root_path
    end

    @connection_ids = current_user.connection_ids

    @formulas = case
                when current_user.is_self?(@user)
                  if @user.client?
                    # guests can see their entire history
                    @user.formulas.first(4)
                  else
                    # artists would see their complete client history
                    @user.guest_formulas.first(6)
                  end
                when current_user.client? && @user.artist?
                  # when a client visists an artists page, should only return their own client history with specific artist.
                  @user.guest_formulas & current_user.formulas
                when current_user.artist? && ( @user.client? || @user.artist? )
                  # when artist visits any client page it shows clients entire general history
                #   @user.formulas.first(10)
                # when current_user.artist? && @user.artist?
                  # when user as artist visits another artists page, it shows the users guest formulas
                  # current_user.guest_formulas.where(client_id: @user.id)
                  @user.formulas.first(10)
                when current_user.client? && @user.client?
                  []
                end

    @formula = @formulas ? @formulas.first : nil

  end

  def edit    # non Devise edit page which also contains a dashboard like info

    @user = User.find(params[:id])
    unless current_user == @user
      flash[:alert] = "You do not have access to this profile"
      redirect_to edit_user_path(current_user)
    end
  end

end
