class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "categorizations", "repos", name: "categorizations_repo_id_fk", column: "repo_id"
    add_foreign_key "categorizations", "categories", name: "categorizations_category_id_fk"
    add_foreign_key "release_types", "repos", name: "release_types_repo_id_fk", column: "repo_id"
    add_foreign_key "release_types", "releases", name: "release_types_release_id_fk"
  end
end
