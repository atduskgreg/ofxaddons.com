require 'rubygems'
require 'bundler/setup'

require './app'
use Rack::MethodOverride
run Sinatra::Application