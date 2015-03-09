class CleanupRepos < ActiveRecord::Migration
  def change
    remove_column :repos, :category_id
    remove_column :repos, :contributor_id
    remove_column :repos, :deleted
    remove_column :repos, :forks
    remove_column :repos, :github_created_at
    remove_column :repos, :github_pushed_at
    remove_column :repos, :incomplete
    remove_column :repos, :not_addon
    remove_column :repos, :owner_avatar_url
    remove_column :repos, :owner_login
    remove_column :repos, :updated
  end
end
