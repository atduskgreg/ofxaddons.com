require 'rubygems'
require 'dm-migrations'
require 'dm-migrations/migration_runner'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://localhost/ofxaddons')

DataMapper::Logger.new(STDOUT, :debug)

migration 1, :convert_user_and_slug_to_Text do
  up do
    modify_table :repos do
      change_column :name, 'text'
      change_column :owner, 'text'
      change_column :parent, 'text'
      change_column :source, 'text'
      change_column :github_slug, 'text'
    end
  end
end

migrate_up!