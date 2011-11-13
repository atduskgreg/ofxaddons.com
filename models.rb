require 'rubygems'
require "bundler/setup"
require 'dm-core'
require 'httparty'
require 'dm-migrations'
require 'dm-aggregates'

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
  property :name, String
  property :owner, String
  property :description, Text
  
  property :last_pushed_at, DateTime
  property :github_created_at, DateTime

  # github source graph
  property :source, String
  property :parent, String

  # to uniquely specify a repo
  property :github_slug, String
  
  property :not_addon, Boolean, :default => false
  property :incomplete, Boolean, :default => false
  
  belongs_to :category, :required => false
  
  def self.exists?(params={})
    Repo.first(:github_slug => "#{params['owner']}/#{params['name']}")
  end
  
  def self.create_from_json(json)
    puts json.inspect
    r = self.new 
    r.name = json["name"]
    r.owner = json["owner"]
    r.description =  json["description"]
    r.last_pushed_at = DateTime.parse(json["pushed_at"]) if json["pushed_at"]
    r.github_created_at = DateTime.parse(json["created_at"]) if json["created_at"]
    r.github_slug = "#{json['owner']}/#{json['name']}"
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
  
  def github_url
    "http://github.com/#{github_slug}"
  end
end

class User
  include DataMapper::Resource
  property :id, Serial

  property :username, String
  property :password, String
end

DataMapper.finalize