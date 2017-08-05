module UserHelper
    
    def joined_with?(user)
        
        (current_user.salon_connections.where("salon_user_id = ?", user.id).exists? &&
            user.inverse_salon_connections.where("user_id = ?", current_user.id).exists?) ||
        (user.salon_connections.where("salon_user_id = ?", current_user.id).exists? &&
            current_user.inverse_salon_connections.where("user_id = ?", user.id).exists? )
        
    end
    
end
