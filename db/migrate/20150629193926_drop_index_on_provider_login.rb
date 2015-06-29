class DropIndexOnProviderLogin < ActiveRecord::Migration
  def change
    remove_index :users, name: "index_users_on_provider_and_login"
  end
end
