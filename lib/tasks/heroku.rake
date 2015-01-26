# HACK HACK: we should really be using the Heroku API for this, but
# it's complicated, and I'm lazy
def heroku(command)
  system("GEM_HOME='' BUNDLE_GEMFILE='' GEM_PATH='' RUBYOPT='' /usr/local/heroku/bin/heroku #{command}")
end

namespace :heroku do

  namespace :production do
    namespace :db do
      desc "make your local db look like production"
      task :pull => [:environment, "db:drop"] do
        heroku("pg:pull HEROKU_POSTGRESQL_PINK_URL ofxaddons --app ofxaddons-cedar")
      end
    end
  end

  namespace :staging do
    namespace :db do
      desc "push a copy of your local db to staging"
      task :push => [:environment, "heroku:staging:db:drop"] do
        heroku("pg:push ofxaddons HEROKU_POSTGRESQL_AMBER_URL --app ofxaddons-staging")
      end

      desc "drop the staging db"
      task :drop => :environment do
        heroku("pg:reset HEROKU_POSTGRESQL_AMBER_URL --app ofxaddons-staging")
      end
    end
  end

end
