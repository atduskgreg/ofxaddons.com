require './importer'
require './app.rb'

desc "This task is called by the Heroku cron add-on"
task :cron do
  begin

  before = Repo.count(:not_addon => false, :is_fork => false, :category => nil)
  
  Importer.do_search("ofx")
#  Importer.update_issues_for_all_repos
  Importer.update_source_for_uncategorized_repos
  Importer.update_forks
  render

  num_new = Repo.count(:not_addon => false, :is_fork => false, :category => nil) - before
  puts num_new
  Importer.send_report("Cron job ran successfully. #{num_new} addons were created.\nlog in here to categorize them: http://ofxaddons.com/admin")
  rescue Exception => e
    Importer.send_report("Something went horribly wrong with the cron job:\n#{e}.")
  end
end

desc "update un-categorized"
task :update_repos do
	Importer.update_source_for_uncategorized_repos
	Importer.update_forks
end

desc "update single repo"
task :update_specific_repo, :arg1 do |t, args|
	#puts "Args was: #{args}"
#	Importer.update_repo(args["arg1"], args.arg2)
	puts "searching for ofx#{args["arg1"]}"
	Importer.do_search("ofx#{args["arg1"]}")
end
