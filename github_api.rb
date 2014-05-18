require 'httparty'

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

    def repository_commits(owner, name, options={})
      raise "owner and name cannot be nil" unless owner && name

      base  = base_uri + "/repos/#{owner}/#{name}/commits"
      url   = add_querystring_params(base, options.merge(CREDENTIALS))
      puts "Github::repository_commits: ".yellow + "fetching #{url} ..."
      get(url, HTTP_OPTIONS)
    end

    def repository_contents(owner, name, options={})
      raise "owner and name cannot be nil" unless owner && name

      path  = options.delete(:path)
      base  = base_uri + "/repos/#{owner}/#{name}/contents#{path}"
      url   = add_querystring_params(base, options.merge(CREDENTIALS))
      puts "Github::repository_contents: ".yellow + "fetching #{url} ..."
      get(url, HTTP_OPTIONS)
    end

    def search_repositories_pager(term, options={}, &blk)
      next_page = (options["page"]) ? options["page"] : 1

      begin
        options  = options.merge("page" => next_page)
        response = search_repositories(term, options)

        # TODO: add some rate limit checking/throttling here (https://developer.github.com/v3/#rate-limiting)

        yield response

        next_page = nil

        # look at the link headers and find the next page of the collection
        response.headers["link"].split(",").each do |link|
          next unless link.index("rel=\"next\"")
          /page=([0-9]+)/ =~ link
          next_page = $1.to_i
          break
        end
      end while(next_page)
    end

    def search_repositories(term, options={})
      # TODO: fetch forks here, or later?
      # opts = { :q => "#{ term }+in:name+fork:true" }
      opts = { :q => "#{ term }+in:name" }
      opts.merge!(CREDENTIALS)
      url = add_querystring_params(base_uri + "/search/repositories", options.merge(opts))
      puts "Github::search_repositories: ".yellow + "fetching #{url} ..."
      get(url, HTTP_OPTIONS)
    end

    def user(user, options={})
      raise "user cannot be nil" unless user

      base  = base_uri + "/users/#{user}"
      url   = add_querystring_params(base, options.merge(CREDENTIALS))
      puts "Github::repository_contents: ".yellow + "fetching #{url} ..."
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
