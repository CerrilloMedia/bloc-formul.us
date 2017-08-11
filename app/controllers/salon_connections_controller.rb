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
      @salon_connection = current_user.salon_connections.find_by(salon_user_id: params[:id])
      
      puts params[:salon_user_id]
      puts @salon_connection
      
      if @salon_connection.delete
         flash[:notice] = "Connection successfully removed."
         redirect_to request.referrer
      else
         flash[:alert] = "Unable to process. Please try again."
         redirect_to request.referrer
      end
  end
  
end
