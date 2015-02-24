class AddAttrsToUsers < ActiveRecord::Migration
  def change
    add_column(:users, :location, :string)
    add_column(:users, :admin, :boolean, default: false)
  end
end
