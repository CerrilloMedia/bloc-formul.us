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
  validates_format_of :email, with: email_regexp

  enum role: [:client, :artist, :admin]

  # default_scope { where("confirmed_at IS NOT NULL") }

  scope :confirmed_client, -> { where("confirmed_at IS NOT NULL AND role = 0") }
  scope :confirmed_artist, -> { where("confirmed_at IS NOT NULL AND role = 1") }

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

  # SEARCH QUERY
  def self.search(search)
      if search.split.count > 1
        terms = search.split
        return where("first_name LIKE ? OR last_name LIKE ?", "%#{terms.first}%", "%#{terms.last}%" )
      else
        return where("email LIKE ? OR first_name LIKE ? OR last_name LIKE ?", "%#{search}%","%#{search}%","%#{search}%" )
      end
  end

  def invite_new(email)
    if User.find_by(email: email).empty?
      puts "message sent!"
      User.invite!( email, self)
      puts self
      self.increment!(:invitations_count)
    end
  end

  def is_self?(user)
      self == user
  end

  def author?(formula)
    self.id == formula.artist_id
  end


end
