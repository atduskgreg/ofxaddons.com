class RefactorRepos < ActiveRecord::Migration
  def change
    rename_column :repos, :owner,          :owner_login
    rename_column :repos, :github_slug,    :full_name
    rename_column :repos, :last_pushed_at, :pushed_at
    rename_column :repos, :is_fork,        :fork
    rename_column :repos, :owner_avatar,   :owner_avatar_url

    change_column_default :repos, :example_count, 0
    change_column_default :repos, :watchers_count, 0

    add_column :repos, :forks_count, :integer, default: 0

    remove_column :repos, :readme
    remove_column :repos, :has_forks

    add_index :repos, [:full_name], name: "index_repos_full_name", using: :btree
  end
end
