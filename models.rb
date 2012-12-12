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

# DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://localhost/ofxaddons')

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
  property :description, Text
  property :readme, Text
  property :forks, Json
  property :most_recent_commit, Json
  property :issues, Json

  property :last_pushed_at, ZonedTime, :required => true
  property :github_created_at, ZonedTime

  # github source graph
  property :source, Text
  property :parent, Text

  property :is_fork, Boolean, :default => false

  # to uniquely specify a repo
  property :github_slug, Text
  
  property :not_addon, Boolean, :default => false
  property :incomplete, Boolean, :default => false
  
  belongs_to :category, :required => false
  
  def self.exists?(params={})
    Repo.first(:github_slug => "#{params['owner']}/#{params['name']}")
  end
  
  def self.create_from_json(json)
    r                    = self.new 
    r.name               = json["name"]
    r.owner              = json["owner"]
    r.description        = json["description"]
    r.last_pushed_at     = Time.parse(json["pushed_at"]) if json["pushed_at"]
    r.github_created_at  = Time.parse(json["created_at"]) if json["created_at"]
    r.github_slug        = "#{json['owner']}/#{json['name']}"
    r.readme             = r.render_readme
    r.forks              = r.get_forks
    r.is_fork            = json["fork"]
    r.most_recent_commit = r.get_most_recent_commit
    r.issues             = r.get_issues
    # if(json["fork"])
    #   r.source = json["source"]
    #   r.parent = json["parent"]
    # end
    unless r.save
      r.errors.each {|e| puts e.red }
      return false
    end
    return true
  end
  
  # def self.search(term)
  #   url = "https://api.github.com/legacy/repos/search/:{term}"
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
    self.readme             = render_readme
    self.forks              = get_forks
    self.most_recent_commit = get_most_recent_commit
    self.issues             = get_issues
    self.is_fork            = json["fork"]

    # if(json["fork"])
    #   self.source = json["source"]
    #   self.parent = json["parent"]
    # end

    unless self.save
      errors.each {|e| puts e.red }
      return false
    end
    return true
  end

  def get_most_recent_commit
    url = "https://api.github.com/repos/:{self.github_slug}/commits"
    puts "fetching most recent commit: #{ url }"
    result = HTTParty.get(url)
    if result.success?
      return result[0]
    else
      return nil
    end
  end
  
  def fresher_forks
    forks.select do |f|
      fork_last_pushed = DateTime.parse f["pushed_at"]
      fork_last_pushed > self.last_pushed_at
    end
  end

  def get_forks
    url = "https://api.github.com/repos/:{self.github_slug}/forks"
    puts "fetching forks: #{ url }"
    result = HTTParty.get(url)
    if result.success?
      return result.parsed_response
    else
      return nil
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

  def get_issues
    result = HTTParty.get("https://api.github.com/repos/:{github_slug}/issues")
    if result.success?
      result.parsed_response
    else
      return nil
    end
  end

  def update_ancestry
    result = HTTParty.get("https://api.github.com/repos/:{github_slug}")
    if result.success?
      if result["source"]
        self.source = result["source"]["full_name"]
      end
      self.is_fork = result["fork"]
      self.save
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
