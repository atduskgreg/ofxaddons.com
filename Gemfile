source "https://rubygems.org"
ruby "2.2.1"

gem "rails", "~>4.2.4"
gem "font-awesome-sass"                         # font icons
gem "high_voltage"                              # serving static pages (wrapped in the layout)
gem "lograge"                                   # denser application logs
gem "omniauth-github", github: "intridea/omniauth-github"
gem "passenger"                                 # web server
gem "pg"                                        # database driver
gem "redis-rails"                               # cache store
gem "simple_form"                               # form builder
gem "slim"                                      # HTML template language

group :production do
  gem "newrelic_rpm"                            # performance monitoring
  gem "rack-cache", require: "rack/cache"       # reverse-proxy http cache
  #gem "redis-rack-cache"
  gem "rails_12factor"                          # heroku-specific stack mods
end

group :assets, :development, :test do
  gem "autoprefixer-rails"                      # automatic vendor-specific CSS prefixing
  gem "bootstrap-sass"                          # SASS port of Bootstrap CSS framework
  gem "coffee-rails"                            # coffeescript asset pipeline integration
  gem "jquery-rails"                            # jQuery integration for rails
  gem "sass-rails"                              # SASS support for rails
  gem "uglifier", ">= 1.3.0"                    # javascript compressor
end

group :bin do
  gem "awesome_print"                           # pretty print ruby objects
  gem "colorize"                                # colorized console output
  gem "httparty"                                # http connection library
  gem "nokogiri"                                # used for scraping readme files
end

group :development, :test do
  gem "byebug"                                  # debugger
  gem "dotenv-rails"                            # loads environment from .env file in development mode
  gem "foreman"                                 # Procfile-based app manager
  gem "immigrant"                               # detect foreign keys and generate migrations to create constraints
  gem "quiet_assets"                              # strip out all the asset serving noise from logs
  gem "spring"                                  # rails preloader
  gem "web-console", '~> 2.0'
  gem "yaml_db"                                 # db data dump to YAML
end
