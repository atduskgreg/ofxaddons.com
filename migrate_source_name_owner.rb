require 'rubygems'
require "bundler/setup"
require 'dm-migrations'
require 'dm-migrations/migration_runner'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/ofxaddons')

DataMapper::Logger.new(STDOUT, :debug)

migration 1, :add_source_name_owner do
  up do
    modify_table :repos do
#       change_column :name, 'text'
#       change_column :owner, 'text'
#       change_column :parent, 'text'
#       change_column :source, 'text'
#       change_column :github_slug, 'text'
		add_column :source_name, 'text'
		add_column :source_owner, 'text'

    end
  end
end

migrate_up!
