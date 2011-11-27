require 'rubygems'
require "bundler/setup"
require 'dm-aggregates'
require 'dm-core'
require 'dm-migrations'
require 'github/markup'
require 'httparty'
require 'nokogiri'

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
  
  property :last_pushed_at, DateTime
  property :github_created_at, DateTime

  # github source graph
  property :source, Text
  property :parent, Text

  # to uniquely specify a repo
  property :github_slug, Text
  
  property :not_addon, Boolean, :default => false
  property :incomplete, Boolean, :default => false
  
  belongs_to :category, :required => false
  
  after :save, :cache_readme

  def self.exists?(params={})
    Repo.first(:github_slug => "#{params['owner']}/#{params['name']}")
  end
  
  def self.create_from_json(json)
    puts json.inspect
    r                   = self.new 
    r.name              = json["name"]
    r.owner             = json["owner"]
    r.description       = json["description"]
    r.last_pushed_at    = DateTime.parse(json["pushed_at"]) if json["pushed_at"]
    r.github_created_at = DateTime.parse(json["created_at"]) if json["created_at"]
    r.github_slug       = "#{json['owner']}/#{json['name']}"
    if(json["fork"])
      r.source = json["source"]
      r.parent = json["parent"]
    end
    r.save
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

  def get_github_readme
    result = HTTParty.get(github_readme_url)
    return result.parsed_response    
  end

  # absolute filesystem path to cached repo assets
  def repo_cache_dir
    File.expand_path(File.dirname(__FILE__)) + "/public/repos/#{github_slug}"
  end

  # absolute filesystem path to cached readme
  def cached_readme_file
    repo_cache_dir + '/readme'    
  end

  # relative path to cached readme
  def cached_readme_url
    '/repos/#{github_slug}/readme'
  end

  def cache_readme
    return if cached_readme_file.nil? || cached_readme_file.empty?

    # make sure the directories in the cache path exist
    FileUtils.mkdir_p(repo_cache_dir)
    
    # from time to time we get an empty readme
    body = get_github_readme
    return if body.nil? || body.empty?

    # render the readme from github out to a file
    File.open(cached_readme_file, "w") do |f|
      f.puts(GitHub::Markup.render(github_readme_filename, body))
    end
  end

end

class User
  include DataMapper::Resource
  property :id, Serial

  property :username, String
  property :password, String
end

DataMapper.finalize
