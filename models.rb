require 'rubygems'
require "bundler/setup"
require "colorize"
require 'dm-aggregates'
require 'dm-core'
require 'dm-migrations'
require 'dm-types'
require 'dm-validations'
require 'dm-zone-types'
require 'github/markup'
require 'httparty'
require 'nokogiri'

require './auth'

#DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/ofxaddons')

class Category
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  
  has n, :repos
  
  def slug
    name.downcase.gsub(/\W/, '')
  end
end

class Repo
  include DataMapper::Resource
  
  property :id, Serial
  property :name, Text
  property :owner, Text
  property :owner_avatar, Text 
  property :description, Text
  property :readme, Text
  property :forks, Json
  property :most_recent_commit, Json
  property :issues, Json
  property :followers, Integer, :default => 0 

  property :has_makefile, Boolean, :default => false
  property :example_count, Integer, :default => 0
  property :has_correct_folder_structure, Boolean, :default => false
  property :has_thumbnail, Boolean, :default => false

  property :last_pushed_at, ZonedTime, :required => true
  property :github_created_at, ZonedTime
  property :github_pushed_at, Text

  # github source graph
  property :source, Text
  property :parent, Text

  property :is_fork, Boolean, :default => false
  property :has_forks, Boolean, :default => false

  # to uniquely specify a repo
  property :github_slug, Text
  # not OF related, these don't show up on any public page
  property :not_addon, Boolean, :default => false
  # not finished, not real OF addon, these show up on unfinished page
  property :incomplete, Boolean, :default => false
  
  property :deleted, Boolean, :default => false  

  belongs_to :category, :required => false

    
  def to_json_hash
    result = {
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

  def self.exists?(params={})
    Repo.first(:github_slug => "#{params['owner']}/#{params['name']}")
  end
  
  def self.create_from_json(json)
# JG: moving this to the Importer
#     if(!json["name"].start_with?('ofx'))
#       puts "Repo's name not starting with 'ofx', not saving"
#       return false
#     end

    r                  = self.new 
    r.name               = json["name"]
    r.is_fork            = json["fork"]
    r.has_forks          = json["forks"] > 0
    if r.is_fork
        r.owner              = json["owner"]['login']
		r.owner_avatar       = json["owner"]["avatar_url"]
  		r.github_slug        = "#{json['full_name']}"
  		r.followers          = json["watchers"]		
	    r.update_ancestry()		
    else
        r.owner              = json["owner"]
        r.owner_avatar       = r.get_owner_avatar_url(r.owner)
    	r.github_slug        = "#{json['owner']}/#{json['name']}"
    	r.most_recent_commit = r.get_most_recent_commit
    	r.followers          = json["followers"]
    end

    r.description        = json["description"]
    r.last_pushed_at     = Time.parse(json["pushed_at"]) if json["pushed_at"]
    r.github_created_at  = Time.parse(json["created_at"]) if json["created_at"]
    r.github_pushed_at	 = json["pushed_at"]
#    r.readme             = r.render_readme
	r.deleted 		 	 = false	
	r.check_features
	
    unless r.save
      r.errors.each {|e| puts e.inspect }
      return false
    end
    return true
  end
  
  # def self.search(term)
  #   url = "http://github.com/api/v2/json/repos/search/#{term}"
  #   json = HTTParty.get(url)
  #   json["repositories"].each do |r|
  #     if !Repo.exists?(:owner => r["owner"], :name => r["name"])
  #       Repo.create_from_json( r )
  #     end
  #   end
  # end

  def update_from_json(json)
  
    self.description        = json["description"]
    self.last_pushed_at     = Time.parse(json["pushed_at"]) if json["pushed_at"]
    self.github_created_at  = Time.parse(json["created_at"]) if json["created_at"]	
    self.github_pushed_at	= json["pushed_at"]
#    self.readme             = render_readme
#    self.issues            = get_issues
    self.is_fork            = json["fork"]
    self.has_forks           = json["forks"] > 0
    if self.is_fork
  		self.followers         = json["watchers"]
  		self.owner_avatar      = json["owner"]["avatar_url"]
  		self.update_ancestry()
  	else
	    self.followers         = json["followers"]
		self.owner_avatar      = get_owner_avatar_url(self.owner)
		self.most_recent_commit = get_most_recent_commit
    end 
    
	self.deleted = false #in case it was re-added
	self.check_features
   
    unless self.save
      errors.each {|e| puts "ERROR: #{e}" }
      return false
    end
    return true
  end

  def get_most_recent_commit
    url = "https://api.github.com/repos/#{self.github_slug}/commits?#$auth_params"
    puts "fetching most recent commit: #{ url }"
    result = HTTParty.get(url)
    if result.success?
      return result[0]
    else
      return nil
    end
  end
  
  def fresher_forks
	  Repo.all(:not_addon => false, :is_fork => true, :source => self.github_slug).select do |r|
         r.last_pushed_at > self.last_pushed_at || (r.followers > self.followers unless r.followers.nil?)
      end
  end

 def get_owner_avatar_url(owner_name)
    url = "https://api.github.com/users/#{owner_name}?#$auth_params"
    result = HTTParty.get(url)
    if result.success?
      return result["avatar_url"]
    else
      return nil
    end
  end

  def check_features
    url = "https://api.github.com/repos/#{github_slug}/contents?#$auth_params"
    puts "fetching repo's contents..."
    content = HTTParty.get(url)
    self.example_count = 0
    has_src_folder = false
#    has_libs_folder = false
# TODO: Check for stray source files in repo
    content.each do |c|
      name = c['name']
      if name == "addon_config.mk" || name == "addon.make"
        self.has_makefile = true
        puts "    Found Makefile!".green
      elsif name.match(/example/i)
        puts "    Found Example!".green
        self.example_count += 1
      elsif name.match(/src/i)
        has_src_folder = true
#      elsif name.match(/libs/i)
#        has_libs_folder = true

#TODO: Maybe we want it to be ofxaddons_thumb or something very specific?
      elsif name.match(/ofxaddon_thumbnail.png/i)
        puts "    Found Thumbnail!".green
        self.has_thumbnail = true
      end
    end

#    if has_src_folder and has_libs_folder
	if has_src_folder
      puts "   Has correct folder structure.".green
      self.has_correct_folder_structure = true
    else
      puts "   Has incorrect folder structure.".yellow
      self.has_correct_folder_structure = false
    end
	
	#JG no need to save again as this is done in the update/create calls now
    #if self.save
    #  errors.each {|e| puts "ERROR: #{e}" }
    #  return false
    #else
    #  return true
    #end
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

  def get_issues
    result = HTTParty.get("https://api.github.com/repos/#{github_slug}/issues?#$auth_params")
    if result.success?
      result.parsed_response
    else
      return nil
    end
  end

  def get_last_update_of_release
    last = settings.ofreleases[0]['version']
    settings.ofreleases.each do |r|
      if(r['date'] > self.last_pushed_at)
        return last
      end
      last = r['version']
    end
    return last
  end

  def update_ancestry
    if self.is_fork
      result = HTTParty.get("https://api.github.com/repos/#{github_slug}?#$auth_params")
	  if result.success? && result["source"]
         self.source = result["source"]["full_name"]
         puts "source of #{self.github_slug} is #{self.source}"
		 self.save
      end
    end
  end

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

  # gets the url to the raw readme file on github
  def scrape_github_readme_url
    result = HTTParty.get(github_url)
    return nil unless result.success?

    # fetch the main github page for this repo and parse it
    doc = Nokogiri::HTML(result)

    # grab the table of files in the repo
    files = doc.css('.js-rewrite-sha')

    # filter out everthing except the readmes. the "blob" bit needs
    # to be in there to filter out directories named "readme"
    files = files.select {|file| file["href"] =~ /\/.+\/blob\/.+\/readme.*/i }

    # bail - no readme
    return nil if files.empty?

    # if there are multiples, then grab the last one
    readme = files.last

    # munge the url to get the raw file url
    url = readme["href"].sub("/blob/", "/raw/")

    return "http://github.com#{url}"
  end

  # fetches the actual readme from github
  def get_github_readme
    return nil if github_readme_url.nil? || github_readme_url.empty?
    puts "fetching readme: #{github_readme_url}\n"
    return http_get_utf8(github_readme_url)
  end

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
