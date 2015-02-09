class DropWatchersCount < ActiveRecord::Migration
  def change
    remove_column :repos, :watchers_count
  end
end
