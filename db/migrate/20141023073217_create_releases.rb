class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.string :version
      t.datetime :released_at
      t.timestamps
    end

    # took these from data/config.yml
    {
      "0.6.1" => "2010-02-11T01:17:27-08:00",
      "0.6.2" => "2010-11-17T11:22:37-08:00",
      "0.7.0" => "2011-07-21T09:52:34-07:00",
      "0.7.1" => "2012-05-28T09:32:18-07:00",
      "0.7.2" => "2012-10-20T10:13:39-07:00",
      "0.7.3" => "2012-11-14T14:39:05-08:00",
      "0.7.4" => "2013-02-15T01:10:38-08:00",
      "0.8.0" => "2013-09-01T05:45:26-08:00"
    }.each do |version, released_at|
      Release.create(version: version, released_at: released_at)
    end

  end
end
