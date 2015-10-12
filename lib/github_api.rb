require "httparty"

class GithubApi

  include HTTParty
  base_uri 'https://api.github.com'

  if ENV['GITHUB_CLIENT_ID']
    CREDENTIALS = {
      "client_id"     => ENV['GITHUB_CLIENT_ID'],
      "client_secret" => ENV['GITHUB_CLIENT_SECRET']
    }
  else
    CREDENTIALS = {}
  end

  HTTP_OPTIONS = {
    :headers => {
      'Accept'     => 'application/vnd.github.v3+json',
      'User-Agent' => 'ofxaddons-spider'
    }
  }

  class << self

    def repository(full_name:, options: {})
      base  = "/repos/#{ full_name }"
      url   = add_querystring_params(base, options.merge(CREDENTIALS))
      Rails.logger.debug "Github::repository: ".yellow + "fetching #{url} ..."
      get(url, HTTP_OPTIONS)
    end

    def repository_commits(full_name:, options: {})
      base  = "/repos/#{ full_name }/commits"
      url   = add_querystring_params(base, options.merge(CREDENTIALS))
      Rails.logger.debug "Github::repository_commits: ".yellow + "fetching #{url} ..."
      get(url, HTTP_OPTIONS)
    end

    def repository_contents(full_name:, options: {})
      path  = options.delete(:path)
      base  = "/repos/#{ full_name }/contents#{path}"
      url   = add_querystring_params(base, options.merge(CREDENTIALS))
      Rails.logger.debug "Github::repository_contents: ".yellow + "fetching #{url} ..."
      get(url, HTTP_OPTIONS)
    end

    # will yield a response object and a page number for each page of search results
    def search_repositories_pager(term:, options: {}, &blk)
      next_page = (options["page"]) ? options["page"] : 1

      begin
        options  = options.merge("page" => next_page)

        # We can only make about 30 requests per minute before we bump into the rate limit
        # https://developer.github.com/v3/#rate-limiting
        try_again = true
        response = begin
          r = search_repositories(term: term, options: options)
          if r.success?
            # we got a valid response - break out of the retry loop
            try_again = false

          elsif r.headers["x-ratelimit-remaining"].try(:to_i) == 0
            Rails.logger.info "Hit Github API rate limit".red

            # figure out how long we need to wait to start making requests again
            # Github tells us this in the response headers
            reset = r.headers["x-ratelimit-reset"].to_i
            reset_time = Time.at(reset)
            seconds = reset_time - Time.now

            # in some cases, due to execution time, seconds can go negative
            if seconds > 0
              Rails.logger.debug "Sleeping for #{seconds} seconds"
              sleep(seconds)
            end
          else
            # we got a bad response... move along
            Rails.logger.error r.headers.inspect
            try_again = false
          end
          r
        end while(try_again)

        yield response, next_page

        next_page = nil

        # look at the link headers and find the next page of the collection
        if response.headers && response.headers["link"]
          response.headers["link"].split(",").each do |link|
            next unless link.index("rel=\"next\"")
            /page=([0-9]+)/ =~ link
            next_page = $1.to_i
            break
          end
        end
      end while(next_page)
    end

    def search_repositories(term:, options: {})
      # TODO: fetch forks here, or later?
      # opts = { :q => "#{ term }+in:name+fork:true" }
      opts = {
        q: "#{ term }+in:name",
        per_page: 100
      }
      opts.merge!(CREDENTIALS)
      url = add_querystring_params("/search/repositories", options.merge(opts))
      Rails.logger.debug "Github::search_repositories: ".yellow + "fetching #{url} ..."
      get(url, HTTP_OPTIONS)
    end

    def user(user:, options: {})
      base  = "/users/#{user}"
      url   = add_querystring_params(base, options.merge(CREDENTIALS))
      Rails.logger.debug "Github::repository_contents: ".yellow + "fetching #{url} ..."
      get(url, HTTP_OPTIONS)
    end

    private

    def add_querystring_params(url, params_hash)
      delim = (url.index('?') ? '&' : '?')

      params_hash.each do |key, value|
        url << "#{ delim }#{ key }=#{ value }"
        delim = '&'
      end

      url
    end

  end

end
