require './models'
require 'colorize'

class Importer

  def self.update_source_for_uncategorized_repos
    repos = Repo.all :not_addon => false, :is_fork => false, :category => nil
    count = repos.length
    repos.each_with_index do |repo,i|
      puts "[#{i+1}/#{count}] finding source for #{repo.github_slug}"
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

  def self.update_issues_for_all_repos
    count = Repo.count(:not_addon => false, :is_fork => false, :category.not => nil)
    Repo.all(:not_addon => false, :is_fork => false, :category.not => nil).each_with_index do |repo, i|
      puts "[#{i+1}/#{count}] Updating Issues for #{repo.name}"
      repo.issues = repo.get_issues
      repo.save
    end
  end

  def self.do_search(term, next_page=1)
    puts "requesting page #{next_page}"
    url = "https://api.github.com/legacy/repos/search/#{term}?start_page=#{next_page}"
    json = HTTParty.get(url)
  
    json["repositories"].each do |r|
      puts r.inspect
  
      # don't bother with repos that have never been pushed
      unless r["pushed_at"]
        puts "skipping:\t".red + "#{ r['owner'] }/#{ r['name'] }\n"
        next
      end
  
      repo = Repo.first(:owner => r["owner"], :name => r["name"])
  
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