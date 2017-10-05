class Formula < ActiveRecord::Base

    belongs_to :user

    validates :artist_id,           presence: true
    validates :formulation,         presence: true, length: { minimum: 5, maximum: 160 }
    validates :author_name,         presence: true
    validates :service_type,        presence: true, length: { minimum: 5, maximum: 50}

    before_validation :set_names, on: :create
    after_create :set_salon_connection

    before_validation :trim_whitespace, on: [:create,:update]
    # before_validation :check_for_self

    default_scope { order('id DESC') }

    def get_author_name
      User.find(self.artist_id).full_name
    end

    def get_client_name
      User.find(self.client_id).full_name
    end

    def current_match
        combinations = ["user_id = #{artist_id} AND salon_user_id = #{client_id}",
                         "user_id = #{client_id} AND salon_user_id = #{artist_id}"]
        SalonConnection.where(combinations.join(' OR '))
    end

    def create_connection(artist, client)

    end

    def parse_client
      puts "Parsing client"
      formula = self unless self.nil?
      # find client by name OR e-mail
      clients = User.search(formula.client_name) || nil
      current_user = User.find(formula.artist_id)

      if clients.size == 1
        # if only one client found, it assigns the id of existing client to formula
        # and generates a connection if there isn't one
        formula.client_id = clients.first.id
        formula.client_name = clients.first.full_name

        sc = current_user.salon_connections.new(salon_user_id: formula.client_id)
        sc.save
        formula.salon_connection_id = sc.id
        
      elsif clients.size > 1
        # if more than one guest exists, assign them to an instance variable for users to choose from
        # possibly through a modal and adjusted in jquery?
        clients = clients
      elsif formula.client_name.match(User.email_regexp)
        puts "generating User: #{formula.client_name}"
        # not found, generate user with e-mail. Don't trigger invite. attach new user id to formula.

        user = User.invite!(email: formula.client_name)
        formula.client_id = user.id
        # generate salon connection:
        sc = current_user.salon_connections.new(salon_user_id: user.id)
        sc.save
        formula.salon_connection_id = sc.id
      end

    end

    private

    def set_salon_connection
        # set connection attribute in formula if already connected
        self.salon_connection_id = current_match.first.id
    end

    def set_names
        if self.author_name.nil?
          self.author_name ||= User.find(artist_id).full_name
        end
    end

    def trim_whitespace
      self.formulation = self.formulation.strip
    end



end
