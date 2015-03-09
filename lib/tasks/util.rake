task :normalize_users => :environment do
  Repo.transaction do
    Repo.all.each do |r|
      unless r.user
        login, repo = r.full_name.split("/")
        if user = User.find_by_login(login)
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
end
