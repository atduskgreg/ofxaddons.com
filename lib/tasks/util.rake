task :normalize_users => :environment do
  Repo.transaction do
    Repo.where("user_id is NULL").each do |r|
      login, repo = r.full_name.split("/")
      if user = User.find_provider_login("github", login)
        r.user = user
        r.save
      else
        response = GithubApi.user(user: login)
        user = User.new
        user.provider = "github"
        user.uid = response.parsed_response["id"]
        user.login = response.parsed_response["login"]
        user.avatar_url =  response.parsed_response["avatar_url"]
        user.location = response.parsed_response["location"]
        user.save
      end
    end
  end
end


task :clean_users => :environment do

  # TODO: User.login not null
  # TODO: User.uid   not null?
  # TODO: make a cron job which validates users and repos against the Github API

  # kill dead users
  ["nistetsurooy", "nocomputer", "slugmobile", "baugsjokket", "endlesscodes", "MartyVi", "ikillbombs"].each do |login|
    User.where("login='#{login}'").map(&:destroy)
  end

  # delete empty users
  User.where("login IS NULL AND uid IS NULL").delete_all


  # dedupe logins
  logins = User.pluck(:login).compact.uniq.sort

  logins.each do |login|
    users    = User.where("login='#{login}'").order("id ASC")
    user_ids = users.map(&:id)

    next if user_ids.size == 1
    raise "more than 2" if user_ids.size > 2

    repos = Repo.where("user_id IN (#{user_ids.join(",")})")
    User.transaction do
      id = users.first.id

      users.first.uid        = users.last.uid
      users.first.name       = users.last.name
      users.first.avatar_url = users.last.avatar_url
      users.first.location   = users.last.location

      repos.map do |r|
        r.user_id = id
        r.save!
      end
      users.last.destroy
      users.first.save
    end
  end

  # backfill uids from avatar_url
  User.all.each do |u|
    if u.uid.nil?
      if u.avatar_url =~ /https:\/\/avatars.githubusercontent.com\/u\/(\d+)\?v=3/
        u.uid = $1
        u.save
      end
    end
  end

end
