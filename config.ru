require 'rubygems'
require 'bundler'
Bundler.setup(:default)
require './app'

use Rack::MethodOverride
run OfxAddons
