class AddAuthorAndClientNameToFormulas < ActiveRecord::Migration
  def change
    add_column :formulas, :author_name, :string
    add_column :formulas, :client_name, :string
  end
end
