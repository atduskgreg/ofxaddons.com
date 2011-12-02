require './importer'

desc "This task is called by the Heroku cron add-on"
task :cron do
  Importer.do_search("ofx")
end