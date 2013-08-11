require './models'
require 'colorize'
require 'pony'
require './auth'

class Importer

  def self.update_source_for_uncategorized_repos
    repos = Repo.all :not_addon => false, :is_fork => false, :category => nil
    count = repos.length
    repos.each_with_index do |repo,i|
      puts "[#{i+1}/#{count}] finding source for #{repo.github_slug}"
      if repo.is_fork
	      repo.update_ancestry
	      if repo.source_repo
	        puts "source: #{repo.source_repo.github_slug} [not_addon: #{repo.source_repo.not_addon}]"
	        repo.not_addon = repo.source_repo.not_addon
	        repo.save
	      else 
	        puts "source unknown"
	      end
	   end
    end
  end
  
  def self.update_forks


    repos = Repo.all :not_addon => false, :is_fork => false, :category.not => nil, :has_forks => true

    count = repos.length
    repos.each_with_index do |source_repo,i|
    
	  if !source_repo.github_pushed_at
	    puts "[#{i+1}/#{count}] #{source_repo.github_slug} does not have a pushed at string, cannot query forks".red
	    next
	  end

      puts "[#{i+1}/#{count}] finding source for #{source_repo.github_slug}"	  

   	  url = "https://api.github.com/repos/#{source_repo.github_slug}/forks?#$auth_params"
	  puts "fetching forks: #{ url }"
	  result = HTTParty.get(url)
	  if result.success?
	  	result.each do |r| 
		  if r["pushed_at"] && DateTime.parse(r["pushed_at"]) > DateTime.parse(source_repo.github_pushed_at)
			  puts "fork pushed at #{DateTime.parse(r["pushed_at"])}, source repo #{DateTime.parse(source_repo.github_pushed_at)}. updating"
		  	  fork_repo = Repo.first(:owner => r['owner']['login'], :name => r['name'])
		      if !fork_repo
		        # create a new record
		        puts "creating fork:\t".green + "#{ r['owner']['login'] }/#{ r['name'] }"
		        #puts "creating fork".green
		        Repo.create_from_json(r)
		      else
		        # update this record
		        puts "updating fork:\t".green + "#{ r['owner']['login'] }/#{ r['name'] }"
		        fork_repo.update_from_json(r)
		      end
		   else
		  	puts "no more recent commits than source, skipping ".red + "#{ r['owner']['login'] }/#{ r['name'] }"
		   end
	    end	  	
	  end
	end
  end  

  def self.update_issues_for_all_repos
    count = Repo.count(:not_addon => false, :is_fork => false, :category.not => nil)
    Repo.all(:not_addon => false, :is_fork => false, :category.not => nil).each_with_index do |repo, i|
      puts "[#{i+1}/#{count}] Updating Issues for #{repo.name}"
      repo.issues = repo.get_issues
      repo.save
    end
  end

  def self.send_report(msg)
    Pony.mail :to => ['greg.borenstein@gmail.com', 'james@jamesgeorge.org'],
      :from => 'greg.borenstein@gmail.com',
      :subject => 'ofxaddons report',
      :body => msg, 
      :via => :smtp,
      :via_options => { 
          :address   => 'smtp.sendgrid.net', 
          :port   => '25', 
          :user_name   => ENV['SENDGRID_USERNAME'], 
          :password   => ENV['SENDGRID_PASSWORD'],
          :authorization => :plain,
          :domain => ENV['SENDGRID_DOMAIN']
        } 
  end

    
  def self.do_search(term, next_page=1)
  	puts "doing search"

    url = "https://api.github.com/legacy/repos/search/#{term}?start_page=#{next_page}&sort=updated&#$auth_params"
    puts "#{url} requesting page #{next_page}"
    json = HTTParty.get(url)
    
    if !json["repositories"]
      puts "NO REPOS"
      return
    end

    json["repositories"].each do |r|
      puts r.inspect
  
      # don't bother with repos that have never been pushed
      unless r["pushed_at"]
        puts "no commits, skipping:\t".red + "#{ r['owner'] }/#{ r['name'] }\n"
        next
      end
  	    
#  	    puts "looking up repo #{ r['owner'] }/#{ r['name'] }"
  	    repo = Repo.first(:owner => r['owner'], :name => r['name'])
  	      	    	    
	    # don't bother with non-addons
	    if repo && repo.not_addon
	      puts "skipping:\t".red + "#{ r['owner'] }/#{ r['name'] }\n"
	      next
	    end

	    if !repo
	      # create a new record
	      puts "creating:\t".green + "#{ r['owner'] }/#{ r['name'] }"
	      Repo.create_from_json(r)
	    else # uncomment this line and comment the next to update all with the latest
	    #elsif r["pushed_at"] && (DateTime.parse(r["pushed_at"]) > repo.last_pushed_at)
	      # update this record
	      puts "updating:\t".green + "#{ r['owner'] }/#{ r['name'] }"
	      repo.update_from_json(r)
	    end
	    
	    puts 
	  	  
    end
 
  
    if json["repositories"].length == 100
      do_search(term, next_page + 1)
    end
  
  end

  
end