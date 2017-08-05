class SalonConnectionsController < ApplicationController

  def create
      @salon_connection = current_user.salon_connections.build(salon_user_id: params[:salon_user_id])
      
      if @salon_connection.save
        flash[:notice] = "Now connected to user."
        redirect_to request.referrer
      else
        flash[:alert] = "Error connecting to user"
        redirect_to request.referrer
      end
  end

  def destroy
      @salon_connection = current_user.salon_connections.where("salon_user_id = ?", params[:id]).first ||
                          current_user.inverse_salon_connections.where("user_id =?", params[:id]).first
      
      if @salon_connection.delete
         flash[:notice] = "Connection successfully removed."
         redirect_to request.referrer
      else
         flash[:alert] = "Unable to process. Please try again."
         redirect_to request.referrer
      end
  end
  
end
