class CreateSupportedReleases < ActiveRecord::Migration
  def up
    create_table :supported_releases do |t|
      t.references :release, index: true
      t.references :repo, index: true
      t.string :type
      t.timestamps
    end

    # estimated release is populated before_save, so let's populate!
    Repo.all.each {|repo| repo.save!}
  end

  def down
    drop_table :supported_releases
  end

end
