class NormalizeOwners < ActiveRecord::Migration
  def up
    add_foreign_key(:repos, :users, dependent: :delete)
    add_column(:users, :avatar_url, :string)

    Addon.all.each do |r|
      u = User.where(provider: "github", login: r.owner_login).first_or_create
      u.avatar_url = r.owner_avatar_url
      u.repos << r
      u.save
    end

  end

  def down
    remove_foreign_key(:repos, :users)
    remove_column(:users, :avatar_url)
  end

end
