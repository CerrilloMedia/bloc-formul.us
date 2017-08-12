class SalonConnectionsController < ApplicationController

  def create
      puts params[:salon_user_id]
      @salon_connection = if current_user.artist?
                            current_user.salon_connections.build(salon_user_id: params[:salon_user_id])
                        else
                            current_user.inverse_salon_connections.build(user_id: params[:salon_user_id])
                        end
     
      if @salon_connection.save
        flash[:notice] = "Now connected to user."
        redirect_to request.referrer
      else
        flash[:alert] = "Error connecting to user"
        @salon_connection.errors.full_messages
        redirect_to request.referrer
        
      end
  end

  def destroy
      
      @salon_connection =   if current_user.artist?
                                current_user.salon_connections.find_by(salon_user_id: params[:id])
                            else
                                current_user.inverse_salon_connections.find_by(user_id: params[:id])
                            end
                            
        puts @salon_connection
                            
      if @salon_connection.delete
         flash[:notice] = "Connection successfully removed."
         redirect_to request.referrer
      else
         flash[:alert] = "Unable to process. Please try again."
         puts errors.messages
         redirect_to request.referrer
      end
  end
  
end
