class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key("categorizations", "repos",      name: "categorizations_repo_id_fk",    column: "repo_id", dependent: :delete)
    add_foreign_key("categorizations", "categories", name: "categorizations_category_id_fk", dependent: :delete)
    add_foreign_key(:repos, :releases, dependent: :delete)
  end
end
