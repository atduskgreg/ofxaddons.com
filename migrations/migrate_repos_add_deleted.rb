require 'rubygems'
require "bundler/setup"
require 'dm-migrations'
require 'dm-migrations/migration_runner'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/ofxaddons')

DataMapper::Logger.new(STDOUT, :debug)

migration 1, :add_deleted do
  up do
    modify_table :repos do
	   add_column :deleted, 'boolean'
    end
  end
end

migrate_up!
