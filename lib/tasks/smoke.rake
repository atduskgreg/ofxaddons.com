
desc "Simple smoke test - hit urls, fail on error. Run this before pushing to production."
task :smoke => :environment do

  HOST = ENV["HOST"] || "localhost:5000"

  # Test cases can be specified as either a simple path OR a Hash with the
  # following keys:
  #
  #  :path  - Relative path (required)
  #  :proto - http or https (default=http)
  #  :code  - Expected http status code (default=200)
  #  :loc   - Expected 'Location' response header (String or Regexp)
  #  :ua    - Pass this user-agent header
  #  :host  - Pass this host header
  #  :only  - Only run against one environment (:dev or :prod)
  #
  # In either case, they will be converted into OpenStructs

  TESTS = [
    "/api/v1/repos",
    "/api/v1/repos/ofXTitles",
    "/api/v1/search",
    "/api/v1/users/jamEZilla",
    "/api/v1/users/jamEZilla/repos",
    "/api/v1/users/jamEZilla/repos/ofXtitles",
    "/categories",
    "/categories/1",
    "/contributors",
    "/contributors/jamEZilla",
    "/freshest",
    "/pages/howto",
    "/popular",
    "/unsorted"
  ].map do |i|

    # Convert everything into a struct
    test = case i
    when Hash
      OpenStruct.new(i)
    else
      OpenStruct.new(path: i)
    end

    # defaults
    test.code ||= 200
    test.proto ||= "http"

    test
  end

  TESTS.each do |i|
    # Prepare headers
    headers = {}
    headers["Host"]       = HOST
    headers["User-Agent"] = i.ua if i.ua

    desc = i.path
    desc = "#{desc} #{headers.inspect}" if headers.present?
    puts desc

    req_options = {
      follow_redirects: false,
      headers: headers
    }

    res = HTTParty.get("#{i.proto}://#{HOST}#{i.path}", req_options)

    # Check status code
    if res.code != i.code
      error = "HTTP status #{res.code} != #{i.code}"
      if [301, 302].include?(res.code)
        error = "#{error} (redirected to loc=#{res.headers["Location"]})"
      end
      raise error
    end

    # Check 'Location' header if the test case specifies one
    if i.loc
      loc = res.headers["Location"]

      # If our test case does not specify a fully-qualified url,
      # then just test against the path
      if i.loc.inspect !~ /http/ && loc
        loc = URI.parse(loc).path
      end

      # Handle string or Regexp
      raise "Wrong redirect: #{loc} !~ #{i.loc}" if !(i.loc === loc)
    end
  end
end
