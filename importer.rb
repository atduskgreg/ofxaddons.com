require 'models'

def do_search(term, next_page=1)
  puts "requesting page #{next_page}"
  url = "http://github.com/api/v2/json/repos/search/#{term}?start_page=#{next_page}"
  json = HTTParty.get(url)
  json["repositories"].each do |r|
    if !Repo.exists?(:owner => r["owner"], :name => r["name"])
      Repo.create_from_json( r )
    end
  end
  if json["repositories"].length == 100
    do_search(term, next_page + 1)
  end
end


do_search("ofx")