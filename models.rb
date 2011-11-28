require 'rubygems'
require "bundler/setup"
require "colorize"
require 'dm-aggregates'
require 'dm-core'
require 'dm-migrations'
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
  
  property :last_pushed_at, ZonedTime, :required => true
  property :github_created_at, ZonedTime

  # github source graph
  property :source, Text
  property :parent, Text

  # to uniquely specify a repo
  property :github_slug, Text
  
  property :not_addon, Boolean, :default => false
  property :incomplete, Boolean, :default => false
  
  belongs_to :category, :required => false
  
  def self.exists?(params={})
    Repo.first(:github_slug => "#{params['owner']}/#{params['name']}")
  end
  
  def self.create_from_json(json)
    r                   = self.new 
    r.name              = json["name"]
    r.owner             = json["owner"]
    r.description       = json["description"]
    r.last_pushed_at    = Time.parse(json["pushed_at"]) if json["pushed_at"]
    r.github_created_at = Time.parse(json["created_at"]) if json["created_at"]
    r.github_slug       = "#{json['owner']}/#{json['name']}"
    r.readme            = r.render_readme
    if(json["fork"])
      r.source = json["source"]
      r.parent = json["parent"]
    end
    unless r.save
      r.errors.each {|e| puts e.red }
      return false
    end
    return true
  end
  
  def self.search(term)
    url = "http://github.com/api/v2/json/repos/search/#{term}"
    json = HTTParty.get(url)
    json["repositories"].each do |r|
      if !Repo.exists?(:owner => r["owner"], :name => r["name"])
        Repo.create_from_json( r )
      end
    end
  end

  def update_from_json(json)
    self.description       = json["description"]
    self.last_pushed_at    = Time.parse(json["pushed_at"]) if json["pushed_at"]
    self.github_created_at = Time.parse(json["created_at"]) if json["created_at"]
    self.readme            = render_readme
    if(json["fork"])
      self.source = json["source"]
      self.parent = json["parent"]
    end
    unless self.save
      errors.each {|e| puts e.red }
      return false
    end
    return true
  end

  def most_recent_commit
    return @most_recent_commit if @most_recent_commit
    url = "https://api.github.com/repos/#{self.github_slug}/commits"
    result = HTTParty.get(url)
    @most_recent_commit = result[0]
  end
  
  def fresher_forks
    forks.select do |f|
      fork_last_pushed = DateTime.parse f["pushed_at"]
      fork_last_pushed > self.last_pushed_at
    end
  end
  
  def forks
    return @forks if @forks
    url = "https://api.github.com/repos/#{self.github_slug}/forks"
    result = HTTParty.get(url)
    @forks = result.parsed_response
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
    # fetch the main github page for this repo and parse it
    doc = Nokogiri::HTML(HTTParty.get(github_url))

    # grab the table of files in the repo
    files = doc.css('.js-rewrite-sha')

    # filter out everthing except the readmes
    readme_files = files.find_all {|file| file.text.downcase.include? "readme" }

    if readme_files.empty?
      # no readme
      return nil
    else
      # if there are multiples, then grab the last one
      readme = readme_files.last
      begin
        # munge the url to get the raw file url
        url = readme["href"].sub("/blob/", "/raw/")
        return "http://github.com#{url}"
      rescue
        return nil
      end
    end
  end

  # fetches the actual readme from github
  def get_github_readme
    return nil if github_readme_url.nil? || github_readme_url.empty?
    puts "fetching readme: #{github_readme_url}\n"
    begin
      result = HTTParty.get(github_readme_url)

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
