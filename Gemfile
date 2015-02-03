source "https://rubygems.org"
ruby "2.1.3"

gem "rails", "~>4.1.9"
gem "actionpack-page_caching"                   # page caching
gem "font-awesome-sass"                         # font icons
gem "foreigner"                                 # support for foreign key constraints
gem 'omniauth-github', :github => 'intridea/omniauth-github'
gem "passenger"                                 # web server
gem "pg"                                        # database driver
gem "slim"                                      # HTML template language

group :production do
  gem "newrelic_rpm"                            # performance monitoring
  gem "rails_12factor"                          # heroku-specific stack mods
  gem "redis-rails"                             # cache store
end

group :assets, :development, :test do
  gem "bootstrap-sass"                          # SASS port of Bootstrap CSS framework
  gem "coffee-rails"                            # coffeescript asset pipeline integration
  gem "jquery-rails"                            # jQuery integration for rails
  gem "sass-rails"                              # SASS support for rails
  gem "uglifier", ">= 1.3.0"                    # javascript compressor
end

group :bin do
  gem "colorize"                                # colorized console output
  gem "httparty"                                # http connection library
  gem "nokogiri"                                # used for scraping readme files
end

group :development, :test do
  gem "awesome_print"                           # pretty print ruby objects
  gem "byebug"                                  # debugger
  gem "dotenv-rails"                            # loads environment from .env file in development mode
  gem "foreman"                                 # Procfile-based app manager
  gem "immigrant"                               # detect foreign keys and generate migrations to create constraints
  gem "quiet_assets"                            # strip out all the asset serving noise from the dev log
  gem "spring"                                  # rails preloader
  gem "yaml_db"                                 # db data dump to YAML
end
