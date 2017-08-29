class User < ActiveRecord::Base

    has_many :salon_connections
    has_many :salon_users, through: :salon_connections
    has_many :inverse_salon_connections, class_name: "SalonConnection", foreign_key: "salon_user_id"
    has_many :inverse_salon_users, through: :inverse_salon_connections, source: :user

    # artists.guest_formulas
    has_many :guest_formulas, foreign_key: :artist_id, class_name: 'Formula'

    # client.formulas
    has_many :formulas, foreign_key: :client_id

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  after_initialize :set_default_role, if: :new_record?

  validates :first_name, :last_name, presence: true, length: { maximum: 20 }

  enum role: [:client, :artist, :admin]

  def set_default_role
    self.role ||= :client
  end

  def full_name
    if self.first_name && self.last_name
      "#{self.first_name.capitalize} #{self.last_name}"
    else
      "#{self.email}"
    end
  end

  def self.matches(user_id)
    Formula.where('client_id = ?', user_id)
  end

  def connection_ids
    # return User.id's connected to self in array
    puts "finding connections for ##{self.id}:"
    ids = []
    SalonConnection.where("user_id = ? OR salon_user_id = ?", self.id, self.id ).map { |connection|
       ids << if connection.user_id == self.id
               connection.salon_user_id
             else
               connection.user_id
             end
    };
    ids
  end

  def is_self?(user)
      self == user
  end

  def author?(formula)
    self.id == formula.artist_id
  end


end
