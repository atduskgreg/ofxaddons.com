class PartitionRepos < ActiveRecord::Migration

  def up
    add_column :repos, :type, :string, default: "Unsorted", null: false
  end

  def down
    remove_column :repos, :type
  end

end
