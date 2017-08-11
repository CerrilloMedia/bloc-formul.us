class User < ActiveRecord::Base

    has_many :salon_connections
    has_many :salon_users, through: :salon_connections
    has_many :formulas, foreign_key: :client_id
    
    has_many :inverse_salon_connections, class_name: "SalonConnection", foreign_key: "salon_user_id"
    has_many :inverse_salon_users, through: :inverse_salon_connections, source: :user
    
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
    puts "checking your connected users:"
    SalonConnection.where("user_id OR salon_user_id = ?", self.id ).map { |connection|
      connection.salon_user_id
    }
  end
  
  def salon_connection(salon_user_id)
      puts salon_user_id
      
      combinations = ["user_id = #{self.id} AND salon_user_id = #{salon_user_id}",
      "user_id = #{salon_user_id} AND salon_user_id = #{self.id}"]
      
      @connection = SalonConnection.where(combinations.join(' OR '))
  end
  
  def author?(formula)
    self.id == formula.artist_id
  end
  
  
end
