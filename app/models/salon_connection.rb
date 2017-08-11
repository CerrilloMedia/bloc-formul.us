class SalonConnection < ActiveRecord::Base
  belongs_to :user
  belongs_to :salon_user, class_name: "User"
  
  validates_uniqueness_of :user_id, :scope => :salon_user_id
  
  validate :check_for_self
  validate :check_for_connection
  
  private
  
  def check_for_self
     if user.id == salon_user.id
         self.errors.add(:user, "Cannot connect to yourself.")
     end
  end
  
  def check_for_connection
        combinations = ["user_id = #{user_id} AND salon_user_id = #{salon_user_id}",
        "user_id = #{salon_user_id} AND salon_user_id = #{user_id}"]
        connection = SalonConnection.where(combinations.join(' OR '))
        if connection.exists?
            self.errors.add(:salon_connection, 'Already friends!')
        end
  end
        
end
