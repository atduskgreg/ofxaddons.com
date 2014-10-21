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
gem 'i18n'                                      # used by activesupport, which is installed by dm-zone-types

# development, importer
gem 'awesome_print'                             # pretty print ruby objects
gem 'colorize'                                  # colorized console output
gem 'dotenv'                                    # loads environment from .env file in development mode

# importer
gem 'creole'                                    # renders creole for readme files
gem 'github-markup', require: 'github/markup'   # renders readme files to HTML
gem 'httparty'                                  # http connection library
gem 'nokogiri'                                  # used for scraping readme files
gem 'pony'                                      # SMTP client
gem 'rake'                                      # Make-like program
gem 'rdoc', '3.6.1'                             # renders rdoc for readme files
gem 'redcarpet'                                 # renders markdown for readme files
gem 'RedCloth'                                  # renders textile for readme files
gem 'wikicloth'                                 # renders wiki markup for readme files

gem 'byebug'
