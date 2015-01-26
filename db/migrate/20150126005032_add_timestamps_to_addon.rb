class AddTimestampsToAddon < ActiveRecord::Migration
  def change
    add_timestamps(:repos)
    Repo.all.each do |r|
      r.created_at = r.github_created_at
      r.updated_at = r.last_pushed_at
    end
  end
end
