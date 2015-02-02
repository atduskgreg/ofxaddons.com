class GithubData

  attr_reader :full_name, :repo_json, :commits_json, :contents_json, :has_makefile, :has_src_folder, :example_count, :has_thumbnail, :has_correct_folder_structure

  # full_name:     the github full_name ':owner/:repo' (eg. 'fubar/ofxTrickyTrick')
  # repo_json:     the json response from GET /repos/:owner/:repo
  # commits_json:  the json respons from GET /repos/:owner/:repo/commits
  # contents_json: the json respons from GET /repos/:owner/:repo/contents
  #
  def initialize(full_name: nil, repo_json: nil, commits_json: nil, contents_json: nil)
    raise "You must initialize with either full_name or repo_json, otherwise other things will blow up" unless full_name || repo_json

    @full_name     = full_name
    @repo_json     = repo_json
    @commits_json  = commits_json
    @contents_json = contents_json
  end

  def attributes
    attrs = {}
    attrs[:created_at]         = DateTime.parse(repo_json["created_at"]) unless repo_json["created_at"].blank?
    attrs[:description]        = repo_json["description"]                unless repo_json["description"].blank?
    attrs[:full_name]          = repo_json["full_name"]                  unless repo_json["full_name"].blank?
    attrs[:forks_count]        = repo_json["forks_count"].to_i           unless repo_json["forks_count"].blank?
    attrs[:fork]               = repo_json["fork"]
    attrs[:name]               = repo_json["name"]                       unless repo_json["name"].blank?
    attrs[:parent]             = repo_json["parent"]["full_name"]        unless repo_json["parent"].blank? || repo_json["parent"]["full_name"].blank?
    attrs[:pushed_at]          = DateTime.parse(repo_json["pushed_at"])  unless repo_json["pushed_at"].blank?
    attrs[:pushed_at]          = repo_json["pushed_at"]                  unless repo_json["pushed_at"].blank?
    attrs[:source]             = repo_json["source"]["full_name"]        unless repo_json["source"].blank? || repo_json["source"]["full_name"].blank?
    attrs[:stargazers_count]   = repo_json["stargazers_count"]           unless repo_json["stargazers_count"].blank?
    attrs[:watchers_count]     = repo_json["watchers_count"]             unless repo_json["watchers_count"].blank?

    unless repo_json["owner"].blank?
      attrs[:owner_avatar_url]   = repo_json["owner"]["avatar_url"]      unless repo_json["owner"]["avatar_url"].blank?
      attrs[:owner_login]        = repo_json["owner"]["login"]           unless repo_json["owner"]["login"].blank?
    end

    attrs[:example_count] = 0

    if contents_json
      contents_json.each do |c|
        name = c['name']
        if name == "addon_config.mk" || name == "addon.make"
          attrs[:has_makefile] = true
          Rails.logger.debug "Found Makefile".green
        elsif name.match(/example/i)
          Rails.logger.debug "Found Example".green
          attrs[:example_count] += 1
        elsif name.match(/src/i)
          attrs[:has_correct_folder_structure] = true
        elsif name.match(/ofxaddons_thumbnail.png/i)
          Rails.logger.debug "Found Thumbnail".green
          attrs[:has_thumbnail] = true
        end
      end
    end

    # Not sure this is worth the extra fetch
    # attrs[:most_recent_commit] = @repo_commits_json.first

    attrs
  end

  def commits_json
    @repo_commits_json ||= get_commits
  end

  def contents_json
    @repo_contents_json ||= get_contents
  end

  def repo_json
    @repo_json ||= get_repo
  end

  def full_name
    # TODO: maybe check commits and contents for the repo name, too
    @full_name || @repo_json["full_name"]
  end

  private

  # TODO: DRY these all up

  # TODO: do some caching
  def get_commits
    raise "can't get a repo without the repo's full_name (eg. 'fubar/ofxTrickyTrick')" unless full_name

    begin
      response = GithubApi::repository_commits(full_name: full_name)
    rescue => ex
      Rails.logger.debug "Failed to get recent commit: #{ex.message} (#{ex.class})"
      return
    end

    unless response.success?
      Rails.logger.debug response.inspect.to_s.red
      return
	end

    @repo_commits_json = response.parsed_response
  end

  # TODO: do some caching
  def get_contents
    raise "can't get a repo without the repo's full_name (eg. 'fubar/ofxTrickyTrick')" unless full_name

    begin
      response = GithubApi::repository_contents(full_name: full_name)
    rescue => ex
      Rails.logger.debug "Failed to get repository contents: #{ex.message} (#{ex.class})"
      return
    end

    unless response.success?
      Rails.logger.debug response.inspect.to_s.red
      return
	end

    @repo_contents_json = response.parsed_response
  end

  # TODO: do some caching
  def get_repo
    raise "can't get a repo without the repo's full_name (eg. 'fubar/ofxTrickyTrick')" unless full_name

    begin
      response = GithubApi::repository(full_name: full_name)
    rescue => ex
      Rails.logger.debug "Failed to get repository: #{ex.message} (#{ex.class})"
      return
    end

    unless response.success?
      Rails.logger.debug response.inspect.to_s.red
      return
	end

    @repo_json = response.parsed_response
  end

end
