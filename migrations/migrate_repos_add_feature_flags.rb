require 'rubygems'
require "bundler/setup"
require 'dm-migrations'
require 'dm-migrations/migration_runner'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/ofxaddons')

DataMapper::Logger.new(STDOUT, :debug)

migration 1, :migrate_repos_add_feature_flags do
  up do
    modify_table :repos do
      add_column :example_count, 'integer'
      add_column :has_makefile, 'boolean'
      add_column :has_correct_folder_structure, 'boolean'
      add_column :thumbnail_url, 'text'
    end
  end
end

migrate_up!