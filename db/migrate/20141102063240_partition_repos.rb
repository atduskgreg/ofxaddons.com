class PartitionRepos < ActiveRecord::Migration

  class Repo < ActiveRecord::Base; end
  class RepoAddon < Repo; end
  class RepoDeleted < Repo; end
  class RepoNonAddon < Repo; end
  class RepoUnsorted < Repo; end

  def up
    add_column :repos, :type, :string, default: "RepoUnsorted", null: false
    Repo.all.each do |r|
      case
      when r.deleted       then r.type = "RepoDeleted";  r.save
      when r.not_addon     then r.type = "RepoNonAddon"; r.save
      when !!r.category_id then r.type = "RepoAddon";    r.save
      end
    end
    remove_column :repos, :category_id
    remove_column :repos, :deleted
    remove_column :repos, :not_addon
  end

  def down
    # yes, I'm too lazy to write this migration. it's actually reversible.
    raise ActiveRecord::IrreversibleMigration
  end

end
