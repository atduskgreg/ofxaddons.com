class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.string :version
      t.datetime :released_at
      t.timestamps
    end

    # took these from data/config.yml
    {
      "0.6.1" => "2010-02-11T00:00:00+00:00",
      "0.6.2" => "2010-11-17T00:00:00+00:00",
      "0.7.0" => "2011-07-21T00:00:00+00:00",
      "0.7.1" => "2012-05-28T00:00:00+00:00",
      "0.7.2" => "2012-10-20T00:00:00+00:00",
      "0.7.3" => "2012-11-14T00:00:00+00:00",
      "0.7.4" => "2013-02-15T00:00:00+00:00",
      "0.8.0" => "2013-09-01T00:00:00+00:00",
      "0.8.1" => "2014-03-28T00:00:00+00:00",
      "0.8.2" => "2014-06-29T00:00:00+00:00",
      "0.8.3" => "2014-07-02T00:00:00+00:00",
      "0.8.3" => "2014-09-09T00:00:00+00:00"
    }.each do |version, released_at|
      Release.create(version: version, released_at: released_at)
    end

    add_column :repos, :release_id, :integer

  end
end
