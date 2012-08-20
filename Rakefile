require './importer'

desc "This task is called by the Heroku cron add-on"
task :cron do
  Importer.do_search("ofx")
  Importer.update_issues_for_all_repos
  Importer.update_source_for_uncategorized_repos
end

desc "update un-categorized"
task :update_repos do
	Importer.update_source_for_uncategorized_repos
end