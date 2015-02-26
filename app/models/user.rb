class User < ActiveRecord::Base

  has_many :repos, inverse_of: :user

  scope :with_addons_count, -> {
    select("users.*, count(users.id) as repo_count")
      .joins(:repos)
      .where("repos.type = 'Addon'")
      .group("users.id")
  }

  #attr_protected :admin

  def self.create_with_omniauth(provider, uid, login, name)
    create! do |user|
      user.provider = provider
      user.uid      = uid
      user.login    = login
      user.name     = name
    end
  end

  # case-insensitive search by provider and uid
  def self.find_provider_uid(provider, uid)
    self.where(table[:provider].matches("%#{ provider }").and(table[:uid].eq(uid))).first
  end

  # case-insensitive search by provider and login
  def self.find_provider_login(provider, login)
    self.where(table[:provider].matches("%#{ provider }").and(table[:login].matches("%#{ login }"))).first
  end

  def self.login(auth)
    login    = auth["extra"]["raw_info"]["login"]
    name     = auth["info"]["name"]
    provider = auth["provider"]
    uid      = auth["uid"]

    if user = (self.find_provider_uid(provider, uid) || self.find_provider_login(provider, login))
      # keep everything up to date
      user.uid   = uid
      user.login = login
      user.name  = name
      user.save
      user
    else
      User.create_with_omniauth(provider, uid, login, name)
    end
  end

  def admin?
    admin
  end

  def to_param
    login.parameterize
  end

  private

  def self.table
    self.arel_table
  end

end
