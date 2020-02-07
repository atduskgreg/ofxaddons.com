# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever


set :output, "/var/log/ofxaddons_importer.log"

job_type :rbenv_runner, %Q{export PATH=/opt/rbenv/shims:/opt/rbenv/bin:/usr/bin:$PATH; eval "$(rbenv init -)"; cd :path && bundle exec rails runner -e :environment ":task" --silent :output }

every 3.months do
  rake "tmp:clear"
end

every 1.hour do
  rbenv_runner "Importer.new.run(no_cache: true)"
end

# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
