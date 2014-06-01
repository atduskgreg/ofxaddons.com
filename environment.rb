if File.exists?("./.env")
  # running in development environment, load environment vars
  require 'dotenv'
  Dotenv.load
end
