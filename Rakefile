require './importer'

desc "This task is called by the Heroku cron add-on"
task :cron do
  before = Repo.count(:not_addon => false, :is_fork => false, :category => nil)
  Importer.do_search("ofx")
  Importer.update_issues_for_all_repos
  Importer.update_source_for_uncategorized_repos

  num_new = before - Repo.count(:not_addon => false, :is_fork => false, :category => nil)
  Importer.send_report("Cron job ran successfully.", num_new)
end

desc "update un-categorized"
task :update_repos do
	Importer.update_source_for_uncategorized_repos
end