require 'rubygems'
require 'bundler/setup'
require './app'
require 'rack-timeout'
 
use Rack::MethodOverride
use Rack::Timeout 
run Sinatra::Application
 
Rack::Timeout.timeout = 100000000000