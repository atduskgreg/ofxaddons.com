require "fileutils"
require "github_data"
require "json"

# TODO: generate some stats:
#       - # repos added
#       - # addons updated
#       - # incomplete repos updated
# TODO: email report
# TODO: import forks
# TODO: import users
# TODO: update issues?
# TODO: move all the paths and glob patterns to constants
# TODO: normalize parent/source

class Importer

  CACHE_BASE_DIR = File.join(Rails.root, "tmp", "importer")

  attr_accessor :items

  def clear_cache
    FileUtils.rm_f(Dir.glob(File.join(CACHE_BASE_DIR, "**", "*")))
  end

  # loads a cached JSON file and returns it as a hash
  def search_file_to_hash(file)
    contents = File.read(file)
    JSON.parse(contents)
  end

  # dumps the raw search results to disk - mainly so you can look
  # through and see what's going on without having to continually
  # download the same thing
  def cache_search_results(term)
    term_dir = File.join(CACHE_BASE_DIR, "search", term)

    FileUtils.mkdir_p(term_dir)

    GithubApi::search_repositories_pager(term: term) do |response, page|
      unless response.success?
        Rails.logger.debug "Bad response #{ response.code }"
        next
      end

      if response.parsed_response["items"].size == 0
        Rails.logger.debug "Search returned no repos".red
        next
      end

      outfile = File.join(term_dir, "#{ page }.json")
      File.open(outfile, "w") do |f|
        f.puts response.body
      end
    end
  end

  def items
    @items ||= load_cached_search_results
  end

  def prune!
    # don't update Deleted and NonAddon repos
    [Deleted, NonAddon].each do |klass|
      full_names = klass.all.pluck(:full_name).to_set
      items.reject! do |i|
        if full_names.include?(i["full_name"])
          Rails.logger.debug "Pruned #{i["full_name"]}: member of #{ klass.to_s }"
          true
        end
      end
    end

    items.select! do |i|
      if !i["name"].match(/^ofx/i)
        # remove repos which don't start with "ofx"
        Rails.logger.debug "Pruned #{i["full_name"]}: doesn't start with ofx"
        false
      elsif i["pushed_at"].nil?
        # remove repos which are empty
        Rails.logger.debug "Pruned #{i["full_name"]}: empty repo"
        false
      else
        true
      end
    end
    # expire the categories fragment caches
    Category.all.each {|c| c.touch }
    items
  end

  def run(no_cache: true)
    if no_cache
      clear_cache
      search
      Rails.logger.debug "Fetched #{items.size} repos from Github"
    else
      Rails.logger.debug "Found #{items.size} cached repos"
    end

    prune!
    Rails.logger.debug "#{items.size} repos after pruning non-addons"

    items.each do |i|
      gd = GithubData.new(repo_json: i)
      update(gd)
    end

    true
  end

  def search
    alphabet = "0123456789abcdefghijklmnopqrstuvwxyz".split("")
    alphabet.each do |letter|
      cache_search_results("ofx" + letter)
    end
  end

  def update(github_data)
    full_name = github_data.full_name
    r = Repo.where(full_name: full_name).first_or_initialize
    repo_attrs = github_data.repo_attributes
    r.assign_attributes(repo_attrs)

    user_attrs = github_data.user_attributes
    user_attrs[:provider] = provider = "github"

    if user_attrs[:uid]
      user = User.where(provider: provider, uid: user_attrs[:uid]).first || User.where(provider: provider, login: user_attrs[:login]).first || User.new
      user.assign_attributes(user_attrs)
      r.user = user
    end

    if r.pushed_at.nil?
      r.type = "Empty"
    elsif !r.has_correct_folder_structure
      r.type = "Incomplete"
    end

    unless r.save
      Rails.logger.debug "Failed to save #{ full_name }: #{ r.errors.inspect }"
    end
  end

  private

  def load_cached_search_results
    items = []
    glob_pattern = File.join(CACHE_BASE_DIR, "search", "**", "*.json")
    Dir.glob(glob_pattern).sort.each do |f|
      # parse the response body to into a hash
      response = search_file_to_hash(f)
      # pull out the search results and add them to our collection
      items.concat(response["items"])
    end
    items
  end

end
