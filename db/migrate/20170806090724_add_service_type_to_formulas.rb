class AddServiceTypeToFormulas < ActiveRecord::Migration
  def change
    add_column :formulas, :service_type, :string
  end
end
