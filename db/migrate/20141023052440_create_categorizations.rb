class CreateCategorizations < ActiveRecord::Migration
  def up
    create_table :categorizations do |t|
      t.references :category, index: true
      t.references :repo, index: true
      t.timestamps
    end
    Repo.all.each { |r| Categorization.create(category_id: r.category_id, repo_id: r.id) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
