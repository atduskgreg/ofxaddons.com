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

  GITHUB_CREDENTIALS = {
    client_id:     ENV['GITHUB_CLIENT_ID'],
    client_secret: ENV['GITHUB_CLIENT_SECRET']
  }

  attr_reader :items
  attr_accessor :options

  def self.run(options = {})
    start_time = Time.now
    importer = new(options)
    importer.run
    logger.debug "Finished in #{(Time.now - start_time).to_i}s"
  end

  def initialize(options = {})
    @options   = options
    @items     = []
  end

  # http caching is off by default for production, on by default for development
  def caching?
    @caching ||= options[:cache] || Rails.env.development?
  end

  def client
    @client ||= begin
      if caching?
        Octokit.middleware = Faraday::RackBuilder.new do |builder|
          builder.use Faraday::HttpCache
          builder.use Octokit::Response::RaiseError
          builder.adapter Faraday.default_adapter
        end
      end

      Octokit::Client.new(GITHUB_CREDENTIALS)
    end
  end

  def items
    @items ||= []
  end

  def logger
    @logger ||= begin
      l = options[:logger] || Rails.logger
      l = ActiveSupport::TaggedLogging.new(l)
      l.push_tags("importer")
      l
    end
  end

  def prune!
    blacklist = [Deleted, NonAddon]
      .map { |klass| klass.all.pluck(:full_name) }
      .flatten
      .to_set

    # save pruned repos for reporting
    pruned = {
      blacklist:  [],
      malformed: [],
      empty:     []
    }

    items.select! do |i|
      if blacklist.include?(i.full_name)
        # don't update Deleted and NonAddon repos
        pruned[:blacklist] << i.full_name
        false
      elsif !i.name.match(/^ofx/i)
        # remove repos which don't start with "ofx"
        pruned[:malformed] << i.full_name
        false
      elsif i.pushed_at.nil?
        # remove repos which are empty
        pruned[:empty] << i.full_name
        false
      else
        true
      end
    end

    logger.tagged("prune") do
      pruned.keys.each do |k|
        pruned[k].sort.each do |n|
          logger.debug "#{ k }: #{ n}"
        end
      end

      logger.debug "pruned #{ pruned.values.map(&:size).reduce(:+) } repos"
    end

    items
  end

  def run
    # make run() idempotent
    items.clear

    search_repositories
    prune!
    logger.debug "#{ items.size } repos after pruning non-addons"

    # items.each do |i|
    #   gd = GithubData.new(repo_json: i)
    #   update(gd)
    # end

    # # expire the categories fragment caches
    # Category.all.each {|c| c.touch }

    true
  end

  def search_repositories
    logger.tagged("search_repos") do

      alphabet = "0123456789abcdefghijklmnopqrstuvwxyz".split("")
      alphabet.each do |letter|
        term = "ofx#{ letter }"

        # fetch the first 100 results
        results = rate_limit { client.search_repositories("#{ term } in:name", per_page: 100) }
        items.concat(results.items)
        logger.debug "term: #{ term }, repos: #{ results.items.size }"

        # keeping fetching the next page of repsonses until we've got it all
        last_response = client.last_response
        if last_response.rels[:next]
          last_href   = last_response.rels[:last].href
          total_pages = get_page(last_href)

          until last_response.rels[:next].nil?
            next_href     = last_response.rels[:next].href
            page          = get_page(next_href)
            last_response = rate_limit do
              last_response.rels[:next].get
            end
            items.concat(last_response.data.items)
            logger.debug "term: #{ term }, repos: #{ last_response.data.items.size } (#{ page }/#{ total_pages })"
          end
        end
      end
      logger.debug "Found #{ items.size } repos on Github"
    end
    self
  end

  private

  def
  end

  def get_page(href)
    if params =  Rack::Utils.parse_query(URI(href).query)
      return params["page"]
    end
  end

  def rate_limit(&block)
    tries ||= 3
    block.call
  rescue Octokit::TooManyRequests => e
    resets_in = client.rate_limit.resets_in + 1
    logger.tagged("rate limit") { logger.debug "sleeping for #{ resets_in }" }
    sleep(resets_in)
    retry if tries > 0
  rescue Exception => e
    logger.error e
  end

end
=begin

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
      logger.debug "Failed to save #{ full_name }: #{ r.errors.inspect }"
    end
  end

=end
