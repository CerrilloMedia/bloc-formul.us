class CreateFormulas < ActiveRecord::Migration
  def change
    create_table :formulas do |t|
      t.integer :artist_id
      t.integer :client_id
      t.text :formulation
      t.integer :salon_connection_id

      t.timestamps null: false
    end
  end
end
