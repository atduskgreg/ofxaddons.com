# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# openframeworks Releases
# TODO: pull this info from the github API (https://github.com/atduskgreg/ofxaddons.com/issues/109)

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
  Release.where(version: version).first_or_create do |r|
    r.released_at = released_at
  end
end
