class Formula < ActiveRecord::Base
    
    validates :artist_id,           presence: true
    validates :client_id,           presence: true
    validates :formulation,         presence: true, length: { minimum: 5}
    validates :salon_connection_id, presence: true
    validates :author_name,         presence: true
    validates :client_name,         presence: true
    
    belongs_to :user
    
    before_validation :set_salon_connection, on: :create
    before_validation :set_names, on: :create
    
    before_validation :check_for_self
    
    def author_name
       User.find(self.artist_id).full_name
    end
    
    def client_name
        User.find(self.client_id).full_name
    end
    
    default_scope { order('id DESC') }
    
    def current_match
        combinations = ["user_id = #{artist_id} AND salon_user_id = #{client_id}",
                         "user_id = #{client_id} AND salon_user_id = #{artist_id}"]
        SalonConnection.where(combinations.join(' OR '))
    end
    
    private
    
    # validation methods
    def check_for_self
        if artist_id == client_id
             self.errors.add(:user, "Cannot connect to yourself.")
        end
    end
    
    def set_salon_connection
        self.salon_connection_id = current_match.first.id
    end
    
    def set_names
        if self.author_name.nil? || self.client_name.nil?
           self.author_name = User.find(artist_id).full_name
           self.client_name = User.find(client_id).full_name
        end
    end
    
end
