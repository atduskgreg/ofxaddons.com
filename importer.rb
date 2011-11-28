require 'models'
require 'colorize'

def do_search(term, next_page=1)
  puts "requesting page #{next_page}"
  url = "http://github.com/api/v2/json/repos/search/#{term}?start_page=#{next_page}"
  json = HTTParty.get(url)

  json["repositories"].each do |r|
    puts r.inspect
    repo = Repo.first(:owner => r["owner"], :name => r["name"])

    # don't bother with non-addons
    if repo && repo.not_addon
      puts "skipping:\t".red + "#{ r['owner'] }/#{ r['name'] }\n"
      next
    end
    
    if !repo
      # create a new record
      puts "creating:\t".green + "#{ r['owner'] }/#{ r['name'] }"
      repo = Repo.create_from_json(r)
    elsif r["pushed_at"] && (DateTime.parse(r["pushed_at"]) > repo.last_pushed_at)
      # update this record
      puts "updating:\t".green + "#{ r['owner'] }/#{ r['name'] }"
      puts repo.update_from_json(r).to_s
    end
    puts
  end

  if json["repositories"].length == 100
    do_search(term, next_page + 1)
  end

end


do_search("ofx")
