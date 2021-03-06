class SalonConnectionsController < ApplicationController

  def create

        @salon_connection = if current_user.artist? || current_user.admin?
                              current_user.salon_connections.build(salon_user_id: params[:salon_user_id])
                          else
                              current_user.inverse_salon_connections.build(user_id: params[:salon_user_id])
                          end



      if @salon_connection.save
        @user = User.find(params[:salon_user_id])
        flash[:notice] = "Now connected to #{@user.full_name}."
        redirect_to local_request?(request.referrer) ? request.referrer : @user
      else
        flash[:alert] = "Error connecting to user"
        @salon_connection.errors.full_messages
        redirect_to request.referrer || @user

      end
  end

  def destroy

      @salon_connection =   if current_user.artist? || current_user.admin?
                                current_user.salon_connections.find_by(salon_user_id: params[:id])
                            else
                                current_user.inverse_salon_connections.find_by(user_id: params[:id])
                            end

      if @salon_connection.delete
         flash[:notice] = "Connection successfully removed."
         redirect_to current_user || root_path
      else
         flash[:alert] = "Unable to remove connection. Please try again."
         puts errors.messages
         redirect_to request.referrer
      end
  end

end
