class Formula < ActiveRecord::Base
    
    validates :artist_id, presence: true
    validates :client_id, presence: true
    validates :card, presence: true, length: { minimum: 30 }
    
end
