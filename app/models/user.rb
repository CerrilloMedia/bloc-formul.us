class User < ActiveRecord::Base

    has_many :salon_connections
    has_many :salon_users, through: :salon_connections
    
    has_many :inverse_salon_connections, class_name: "SalonConnection", foreign_key: "salon_user_id"
    has_many :inverse_salon_users, through: :inverse_salon_connections, source: :user
    
    has_many :guest_formulas, foreign_key: :artist_id, class_name: 'Formula'
    has_many :formulas, foreign_key: :client_id
    
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
         
  after_initialize :set_default_role, if: :new_record?
  
  enum role: [:client, :artist, :admin]
  
  def set_default_role
    self.role ||= :client
  end
  
  def self.matches(user_id)
    Formula.where('client_id = ?', user_id)
  end
  
  def connections
    SalonConnection.where("user_id OR salon_user_id = ?", self.id ).map { |connection|
        connection.user_id == self.id ? connection.salon_user_id : connection.user_id
    }
  end
  
  def salon_connection(salon_user_id)
      combinations = ["user_id = #{self.id} AND salon_user_id = #{salon_user_id}",
      "user_id = #{salon_user_id} AND salon_user_id = #{self.id}"]
      @connection = SalonConnection.where(combinations.join(' OR '))
  end
  
  def is_self?(user)
      self == user
  end
  
  def author?(formula)
    self.id == formula.artist_id
  end
  
  
end
