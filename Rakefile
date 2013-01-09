require './importer'

desc "This task is called by the Heroku cron add-on"
task :cron do
  begin

  before = Repo.count(:not_addon => false, :is_fork => false, :category => nil)
  
  Importer.do_search("ofx")
  Importer.update_issues_for_all_repos
  Importer.update_source_for_uncategorized_repos

  num_new = Repo.count(:not_addon => false, :is_fork => false, :category => nil) - before
  Importer.send_report("Cron job ran successfully. #{num_new} addons were created.\nlog in here to categorize them: http://ofxaddons.com/admin")
  rescue Exception => e
    Importer.send_report("Something went horribly wrong with the cron job:\n#{e}.")
  end
end

desc "update un-categorized"
task :update_repos do
	Importer.update_source_for_uncategorized_repos
end