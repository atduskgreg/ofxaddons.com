source "https://rubygems.org"
ruby "2.1.3"

gem "rails", "~>4.1.6"
gem "actionpack-page_caching"                   # page caching
gem "font-awesome-sass"                         # font icons
gem "foreigner"                                 # support for foreign key constraints
gem "passenger"                                 # web server
gem "pg"                                        # database driver
gem "slim"                                      # HTML template language
gem "sorcery"                                   # authentication

group :production do
  gem "newrelic_rpm"                            # performance monitoring
  gem "rails_12factor"                          # heroku-specific stack mods
  gem "redis-rails"                             # cache store
end

group :assets, :development do
  gem "autoprefixer-rails"                      # CSS vendor prefix generator
  gem "bootstrap-sass"                          # SASS port of Bootstrap CSS framework
  gem "coffee-rails"                            # coffeescript asset pipeline integration
  gem "jquery-rails"                            # jQuery integration for rails
  gem "sass-rails"                              # SASS support for rails
  gem "uglifier", ">= 1.3.0"                    # javascript compressor
end

group :bin do
  gem "httparty"                                # http connection library
  gem "nokogiri"                                # used for scraping readme files
end

group :development do
  gem "awesome_print"                           # pretty print ruby objects
  gem "byebug"                                  # debugger
  gem "colorize"                                # colorized console output
  gem "dotenv"                                  # loads environment from .env file in development mode
  gem "foreman"                                 # Procfile-based app manager
  gem "immigrant"                               # detect foreign keys and generate migrations to create constraints
  gem "quiet_assets"                            # strip out all the asset serving noise from the dev log
  gem "spring"                                  # rails preloader
  gem "yaml_db"                                 # db data dump to YAML
end
