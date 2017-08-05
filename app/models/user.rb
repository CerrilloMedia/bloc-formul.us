class User < ActiveRecord::Base

    has_many :salon_connections
    has_many :salon_users, through: :salon_connections
    
    has_many :inverse_salon_connections, class_name: "SalonConnection", foreign_key: "salon_user_id"
    has_many :inverse_salon_uesrs, through: :inverse_salon_connections, source: :user

    
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
         
  after_initialize :set_default_role, :if => :new_record?
  
  enum role: [:client, :artist, :admin]
  
  def set_default_role
    self.role ||= :client
  end
  
end
