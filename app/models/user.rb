class User < ActiveRecord::Base

  def self.login(auth)
    if user = (User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.find_by_provider_and_login(auth["provider"], auth["extra"]["raw_info"]["login"]))
      # keep everything up to date
      user.uid   = auth["uid"]
      user.login = auth["extra"]["raw_info"]["login"]
      user.name  = auth["info"]["name"]
      user.save
      user
    else
      User.create_with_omniauth(auth)
    end
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.login = auth["extra"]["raw_info"]["login"]
      user.name = auth["info"]["name"]
    end
  end

end
