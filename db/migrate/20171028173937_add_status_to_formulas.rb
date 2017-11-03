class AddStatusToFormulas < ActiveRecord::Migration
  def change
    add_column :formulas, :status, :integer
  end
end
