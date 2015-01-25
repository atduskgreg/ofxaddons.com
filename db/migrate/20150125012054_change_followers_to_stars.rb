class ChangeFollowersToStars < ActiveRecord::Migration
  def change
    rename_column :repos, :followers, :watchers_count
    add_column :repos, :stargazers_count, :integer, default: 0
  end
end
