class CreateSalonConnections < ActiveRecord::Migration
  def change
    create_table :salon_connections do |t|
      t.integer :user_id, foreign_key: true
      t.integer :salon_user_id, foreign_key: true
      
      t.timestamps null: false
    end
    
  end
end
