source "http://rubygems.org"

ruby "2.0.0"
# TODO: make some bundler groups so we don't require everything in every process

# web app
gem 'sinatra'                                   # web application framework
gem 'sinatra-contrib'	                        # used for YAML config files http://www.sinatrarb.com/contrib/config_file.html
gem 'unicorn'                                   # web server
gem 'newrelic_rpm'

# web app, importer
gem 'aws-s3'                                    # Amazon S3 client
gem 'dm-aggregates'                             # count/min/max/avg/sum functions for db collections
gem 'dm-core'                                   # ORM library
gem 'dm-migrations'                             # database migrations
gem 'dm-postgres-adapter'                       # postgres connection adapter
gem 'dm-types'                                  # extended database types (noteably JSON)
gem 'dm-validations'                            # gives us usefull errors for datamapper pukes
gem 'httparty'                                  # http connection library (this shouldn't be in the default group, but models has a bad dependency on it)
gem 'i18n'                                      # used by activesupport, which is installed by dm-zone-types

group :development do
  gem 'awesome_print'                             # pretty print ruby objects
  gem 'dotenv'                                    # loads environment from .env file in development mode
  gem 'byebug'
end

group :importer do
  gem 'nokogiri'                                  # used for scraping readme files
  gem 'pony'                                      # SMTP client
  gem 'rake'                                      # Make-like program
  gem 'rdoc', '3.6.1'                             # renders rdoc for readme files
  # gem 'creole'                                    # renders creole for readme files
  # gem 'github-markup', require: 'github/markup'   # renders readme files to HTML
  # gem 'redcarpet'                                 # renders markdown for readme files
  # gem 'RedCloth'                                  # renders textile for readme files
  # gem 'wikicloth'                                 # renders wiki markup for readme files
end

group :development, :importer do
  gem 'colorize'                                  # colorized console output
end
