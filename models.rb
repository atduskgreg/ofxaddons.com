require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'time'
require './github_api'      # TODO: remove this dependency from the models, this should be in some kind of service object

#DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/ofxaddons')

class Category
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  property :avatar_url, Text

  has n, :repos

  def slug
    name.downcase.gsub(/\W/, '')
  end
end

class Contributor
  include DataMapper::Resource

  property :id,         Serial
  property :login,      Text,  :required => true, :unique => true
  property :name,       Text
  property :avatar_url, Text
  property :location,   Text

  has n, :repos
end

class Repo
  include DataMapper::Resource

  # TODO: rename github_slug -> full_name
  # TODO: rename followers   -> watcher_count
  # TODO: remove has_forks, add fork_count propery and method has_forks?()
  # TODO: remove is_fork, duplicated by 'source', add method is_fork?
  # TODO: remove user_id (only in the db, but obviously not used anymore)
  # TODO: remove owner, it duplicates the functionality of contributor
  # TODO: remove owver_avatar, it duplicates the functionality of contributor
  # TODO: last_pushed_at & github_pushed_at... pick one, delete the other?

  property :deleted,                      Boolean,   :default => false
  property :description,                  Text
  property :example_count,                Integer,   :default => 0
  property :followers,                    Integer,   :default => 0
  property :forks,                        Json
  property :github_created_at,            DateTime
  property :github_pushed_at,             Text
  property :github_slug,                  Text                          # to uniquely specify a repo
  property :has_correct_folder_structure, Boolean,   :default => false
  property :has_forks,                    Boolean,   :default => false
  property :has_makefile,                 Boolean,   :default => false
  property :has_thumbnail,                Boolean,   :default => false
  property :id,                           Serial
  property :incomplete,                   Boolean,   :default => false  # not a fully baked addon yet
  property :is_fork,                      Boolean,   :default => false
  property :issues,                       Json
  property :last_pushed_at,               DateTime, :required => true
  property :most_recent_commit,           Json
  property :name,                         Text
  property :not_addon,                    Boolean,   :default => false  # not OF-related at all
  property :owner,                        Text
  property :owner_avatar,                 Text
  property :parent,                       Text                          # the repo this fork is directly forked from
  property :readme,                       Text
  property :source,                       Text                          # the origial repo from which all forks descend
  property :updated,                      Boolean,   :default => false  # utility flag for the importer

  belongs_to :category,    :required => false
  belongs_to :contributor, :required => false


  def self.exists?(params={})
    Repo.first(:github_slug => "#{params['owner']}/#{params['name']}")
  end

  # TODO: move this to the importer, or a service object
  def self.create_from_json(json)
    repo = self.new
    repo.update_from_json(json)
  end

  def self.set_all_updated_false
    DataMapper.repository(:default).adapter.execute("UPDATE repos SET updated = 'f'")
  end

  # TODO: move this to the importer, or a service object
  def update_from_json(json)
    self.check_features
    self.contributor        = self.get_contributor json['owner']['login']
    self.deleted 		 	= false
    self.description        = json['description']
    self.followers          = json['watchers_count']
    self.github_created_at  = DateTime.parse(json['created_at']) unless json['created_at'].blank?
    self.github_pushed_at	= json['pushed_at']
    self.github_slug        = json['full_name']
    self.has_forks          = json['forks_count'] > 0
    self.is_fork            = json['fork']
    self.last_pushed_at     = DateTime.parse(json['pushed_at']) unless json['pushed_at'].blank?
    self.name               = json['name']
    self.owner              = json['owner']['login']
    self.owner_avatar       = json['owner']['avatar_url']
    self.parent             = json['parent']
    self.source             = json['source']
    # self.readme             = self.render_readme

    self.most_recent_commit = self.get_most_recent_commit

    # flag this repository as updated
    self.updated            = true

    begin
      if self.save
        return true
      else
        self.errors.each {|e| puts e.inspect }
        return false
      end
    rescue => e
      puts self.inspect
      puts
      raise e
    end
  end

  # TODO: move this to the importer, or a service object
  # TODO: this should either be a class method, or make use of the fact that it's an instance method
  def get_contributor(user_login)
    user = Contributor.first :login => user_login
    unless user
      begin
        response = GithubApi::user(user_login)
      rescue => ex
        puts "Failed to get user: #{ex.message} (#{ex.class})"
        puts self.inspect
        puts ex.backtrace
        return
      end

      if response.success?
        data            = response.parsed_response
        user            = Contributor.new
        user.login      = data["login"]
        user.name       = data["name"]
        user.avatar_url = data["avatar_url"]
        unless user.save
          user.errors.each {|e| puts e.inspect }
        end
      end
    end
    return user
  end

  def to_json_hash
    {
      :name => name,
      :owner => owner,
      :description =>  description,
      :last_pushed_at => last_pushed_at,
      :github_created_at => github_created_at,
      :category => category.name,
      :homepage => "https://github.com/#{github_slug}",
      :clone_url => "https://github.com/#{github_slug}.git",
      :warning_labels => warning_labels
    }
  end
  
  def to_json_hash_v2
    {
      :name => name,
      :owner => owner,
      :description =>  description,
      :github_created_at => github_created_at,
      :category => category.name,
      :homepage => "https://github.com/#{github_slug}",
      :clone_url => "https://github.com/#{github_slug}.git",
      :warning_labels => warning_labels,
      :latest_commit => { 
        :sha => (most_recent_commit.nil?) ? "" :  most_recent_commit['sha'], 
        :date => last_pushed_at, 
        :message => (most_recent_commit.nil?) ? "" : most_recent_commit['commit']['message'] 
      }
    }
  end

  # TODO: move this to the importer, or a service object
  def get_most_recent_commit
    raise "need an owner and a name for this repository to fetch its commits" unless self.name && self.owner

    begin
      response = GithubApi::repository_commits(self.owner, self.name)
    rescue => ex
      puts "Failed to get recent commit: #{ex.message} (#{ex.class})"
      puts ex.backtrace
      return
    end

    if response.success?
      return response.parsed_response[0]
    else
      return nil
    end
  end

  def fresher_forks
    Repo.all(:not_addon => false, :is_fork => true, :source => self.github_slug).select do |r|
      r.last_pushed_at > self.last_pushed_at || (r.followers > self.followers unless r.followers.nil?)
    end
  end

  # TODO: move this to the importer, or a service object
  def check_features
    begin
      response = GithubApi::repository_contents(self.owner, self.name)
    rescue => ex
      puts "Failed to get repository contents: #{ex.message} (#{ex.class})"
      puts self.inspect
      puts ex.backtrace
      return
    end

    unless response.success?
      puts response.inspect.to_s.red
      return
	end

    self.example_count = 0
    has_src_folder = false

    response.parsed_response.each do |c|
      name = c['name']
      if name == "addon_config.mk" || name == "addon.make"
        self.has_makefile = true
        puts "\t- Found Makefile!".green
      elsif name.match(/example/i)
        puts "\t- Found Example!".green
        self.example_count += 1
      elsif name.match(/src/i)
        has_src_folder = true
        #TODO: Maybe we want it to be ofxaddons_thumb or something very specific?
      elsif name.match(/ofxaddons_thumbnail.png/i)
        puts "\t- Found Thumbnail!".green
        self.has_thumbnail = true
      end
    end

	if has_src_folder
      puts "\t- Has correct folder structure.".green
      self.has_correct_folder_structure = true
    else
      puts "\t- Has incorrect folder structure.".yellow
      self.has_correct_folder_structure = false
    end

  end

  # find currently open issues on the repo whose title
  # matches one of our tags. Wish we could do this with labels
  # but it looks like only repo owners can apply labels to issues
  #
  # Current labels: ofx-incomplete, ofx-osx, ofx-win, ofx-linux
  #     (the OS-specific ones indicate a problem on that OS)
  def warning_labels
    our_labels = ["ofx-incomplete", "ofx-osx", "ofx-win", "ofx-linux"]
    relevant_labels = []
    if issues
      issues.select{|issue| issue["state"] == "open"  }.each do |issue|
        our_labels.each do |l|
          if Regexp.new(l) =~ issue["title"]
            relevant_labels << l
          end
        end
      end
    end
    relevant_labels
  end

  # TODO: move this to the importer, or a service object
  # TODO: fixme, need to be updated to work with Github API V3
  # def get_issues
  #   result = HTTParty.get("https://api.github.com/repos/#{github_slug}/issues?#$auth_params")
  #   if result.success?
  #     result.parsed_response
  #   else
  #     return nil
  #   end
  # end

  def get_last_update_of_release
    last = OfxAddons.settings.ofreleases[0]['version']
    OfxAddons.settings.ofreleases.each do |r|
      if(r['date'].to_datetime > self.last_pushed_at)
        return last
      end
      last = r['version']
    end
    return last
  end

  def is_fork?
    !self.source.nil?
  end

  # TODO: move this to the importer, or a service object
  # TODO: fixme, need to be updated to work with Github API V3
  # def update_ancestry
  #   if is_fork?
  #     result = HTTParty.get("https://api.github.com/repos/#{github_slug}?#$auth_params")
  #     if result.success? && result["source"]
  #       self.source = result["source"]["full_name"]
  #       puts "source of #{self.github_slug} is #{self.source}"
  #       self.save
  #     end
  #   end
  # end

  def source_repo
    Repo.first :github_slug => self.source
  end

  def github_url
    "http://github.com/#{github_slug}"
  end

  # this is just a caching wrapper around scrape_github_readme_url
  def github_readme_url
    @github_readme_url ||= scrape_github_readme_url
  end

  # gives you the filename of the original readme so the renderer
  # knows which markup engine to use
  def github_readme_filename
    if github_readme_url.nil?
      return nil
    else
      return github_readme_url.split("/")[-1]
    end
  end

  # TODO: move this to the importer, or a service object
  # TODO: fixme, need to be updated to work with Github API V3
  # gets the url to the raw readme file on github
  # def scrape_github_readme_url
  #   result = HTTParty.get(github_url)
  #   return nil unless result.success?

  #   # fetch the main github page for this repo and parse it
  #   doc = Nokogiri::HTML(result)

  #   # grab the table of files in the repo
  #   files = doc.css('.js-rewrite-sha')

  #   # filter out everthing except the readmes. the "blob" bit needs
  #   # to be in there to filter out directories named "readme"
  #   files = files.select {|file| file["href"] =~ /\/.+\/blob\/.+\/readme.*/i }

  #   # bail - no readme
  #   return nil if files.empty?

  #   # if there are multiples, then grab the last one
  #   readme = files.last

  #   # munge the url to get the raw file url
  #   url = readme["href"].sub("/blob/", "/raw/")

  #   return "http://github.com#{url}"
  # end

  # fetches the actual readme from github
  def get_github_readme
    return nil if github_readme_url.nil? || github_readme_url.empty?
    puts "fetching readme: #{github_readme_url}\n"
    return http_get_utf8(github_readme_url)
  end

  # TODO: move this to the importer, or a service object
  # renders the readme using the proper markup engine
  def render_readme
    # from time to time we get an empty readme
    body = get_github_readme
    return nil if body.nil? || body.empty?

    # render the readme
    if plaintext?(github_readme_filename)
      return "<pre>#{ body }</pre>"
    else
      return GitHub::Markup.render(github_readme_filename, body)
    end
  end

  private

  def http_get_utf8(url)
    begin
      result = HTTParty.get(github_readme_url)
      return nil unless result.success?

      # github returns the readme as a binary file type, so we need to
      # set it's encoding explicitly
      body = result.parsed_response.force_encoding("ISO-8859-1")

      unless body.valid_encoding?
        puts "Skipping the readme... it's encoding is all jacked up"
        return nil
      end

      # there are very likely unicode characters
      body = body.encode("UTF-8")

      return body
    rescue
      return nil
    end
  end

  def plaintext?(filename)
    (filename.downcase == "readme") ? true : false
  end

end

class User
  include DataMapper::Resource
  property :id, Serial

  property :username, String
  property :password, String
end

DataMapper.finalize
