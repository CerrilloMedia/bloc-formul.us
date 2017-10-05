class UsersController < ApplicationController
  before_action :authenticate_user!
  # include DeviseInvitable::Inviter

  def index

    @users =  if current_user.artist?
                  # User.confirmed_client
                  User.all
              elsif current_user.client?
                  User.confirmed_artist
              else
                  User.all
              end

    @connection_ids = current_user.connection_ids

    if params[:search]
      @users = @users.search(params[:search]) unless params[:search].strip.empty?
    else
      params[:search] = ""
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
                  @user.guest_formulas.where('client_id = ?', current_user.id)
                when current_user.artist? && @user.client?
                  # when artist visits any client page it shows clients entire general history
                  @user.formulas.first(10)
                when current_user.artist? && @user.artist?
                  # when user as artist visits another artists page, it shows the users guest formulas
                  @user.guest_formulas.first(10)
                when current_user.client? && @user.client?
                  []
                end

    @formula = @formulas ? @formulas.first : nil

  end

  def edit
    @user = User.find(current_user.id)
  end

end
