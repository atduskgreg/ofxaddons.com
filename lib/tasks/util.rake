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
