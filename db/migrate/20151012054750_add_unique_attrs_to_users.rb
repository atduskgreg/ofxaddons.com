class AddUniqueAttrsToUsers < ActiveRecord::Migration
  def change
    remove_column(:categories, :login, :avatar_url)
    change_column_null(:categories, :name, false)

    Categorization.where("repo_id IS NULL").delete_all
    change_column_null(:categorizations, :category_id, false)
    change_column_null(:categorizations, :repo_id, false)

    Release.where("version IS NULL").delete_all
    change_column_null(:releases, :version, false)
    change_column_null(:releases, :released_at, false)

    change_column_null(:users, :provider, false)
    change_column_null(:users, :login, false)
    add_index(:users, [:provider, :login], unique: true)
    add_index(:users, [:provider, :avatar_url], unique: true)
  end
end
