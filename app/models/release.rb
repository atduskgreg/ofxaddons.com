class Release < ActiveRecord::Base

  has_many :addons, inverse_of: :release, foreign_key: :repo_id

end
