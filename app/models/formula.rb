class Formula < ActiveRecord::Base
    
    validates :artist_id,           presence: true
    validates :client_id,           presence: true
    validates :formulation,         presence: true, length: { minimum: 5}
    validates :salon_connection_id, presence: true
    
    belongs_to :user
    
    before_validation :set_salon_connection, on: :create
    before_validation :check_for_self
    
    private
    
    def check_for_self
        if artist_id == client_id
             self.errors.add(:user, "Cannot connect to yourself.")
        end
    end
    
    default_scope { order('id DESC') }
    
    def set_salon_connection
        artist = User.find(artist_id)
        self.salon_connection_id = current_match.first.id || nil
    end
    
    def current_match
        combinations = ["user_id = #{artist_id} AND salon_user_id = #{client_id}",
                         "user_id = #{client_id} AND salon_user_id = #{artist_id}"]
        SalonConnection.where(combinations.join(' OR '))
    end
    
end
