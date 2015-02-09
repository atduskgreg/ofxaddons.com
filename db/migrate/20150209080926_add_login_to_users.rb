class AddLoginToUsers < ActiveRecord::Migration
  def change
    add_column :users, :login, :string
    add_index(:users, [:provider, :login], unique: true)
  end
end
