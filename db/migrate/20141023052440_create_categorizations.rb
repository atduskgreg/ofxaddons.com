class CreateCategorizations < ActiveRecord::Migration
  def up
    create_table :categorizations do |t|
      t.references :category, index: true
      t.references :repo, index: true
      t.timestamps
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
