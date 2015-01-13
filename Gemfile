source 'https://rubygems.org'
ruby "2.1.3"

gem "rails", "~>4.1.6"
gem "passenger"                                 # web server
gem "pg"                                        # database driver
gem "sorcery"                                   # authentication

group :bin do
  gem "httparty"                                # http connection library
  gem "nokogiri"                                # used for scraping readme files
end

group :development do
  gem "autoprefixer-rails"                      # CSS vendor prefix generator
  gem "awesome_print"                           # pretty print ruby objects
  gem "bootstrap-sass"                          # SASS port of Bootstrap CSS framework
  gem "byebug"                                  # debugger
  gem "coffee-rails"                            # coffeescript asset pipeline integration
  gem "colorize"                                # colorized console output
  gem "dotenv"                                  # loads environment from .env file in development mode
  gem "foreigner"                               # support for foreign key constraints
  gem "foreman"                                 # Procfile-based app manager
  gem "immigrant"                               # detect foreign keys and generate migrations to create constraints
  gem "jquery-rails"                            # jQuery integration for rails
  gem "quiet_assets"                            # strip out all the asset serving noise from the dev log
  gem "sass-rails"                              # SASS support for rails
  gem "spring"                                  # rails preloader
  gem "uglifier", ">= 1.3.0"                    # javascript compressor
  gem "yaml_db"                                 # db data dump to YAML
end
