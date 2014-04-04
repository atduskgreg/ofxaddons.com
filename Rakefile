require './importer'
require './app.rb'

desc "This task is called by the Heroku cron add-on"
task :cron do
  begin

    before = Repo.count(:not_addon => false, :is_fork => false, :category => nil, :deleted => false)

    Repo.set_all_updated_false
    Importer.import_from_search("ofx")
    # Importer.update_issues_for_all_repos
    # Importer.update_source_for_uncategorized_repos
    # Importer.update_forks
    # Importer.purge_deleted_repos

    num_new = Repo.count(:not_addon => false, :is_fork => false, :category => nil, :deleted => false) - before
    puts num_new
    Importer.send_report("Cron job ran successfully. #{num_new} addons were created.\nlog in here to categorize them: http://ofxaddons.com/admin")
  rescue Exception => e
    puts e
    Importer.send_report("Something went horribly wrong with the cron job:\n#{e}.")
  end

  #update cache
  bake_html

end

desc "update un-categorized"
task :update_repos do

  # Importer.update_source_for_uncategorized_repos
  Importer.update_forks
  #needs fix
  #	Importer.purge_deleted_repos

end

desc "update single repo"
task :update_specific_repo, :arg1 do |t, args|
  puts "searching for ofx#{args["arg1"]}"
  Importer.import_from_search("ofx#{args["arg1"]}")
end

desc "purge deleted repos"
task :purge_deleted_repos do
  Importer.purge_deleted_repos
end

desc "update cache"
task :update_cache do
  bake_html
end
