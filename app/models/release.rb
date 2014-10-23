class Release < ActiveRecord::Base

  has_many :estimated_releases, inverse_of: :release, dependent: :destroy

end
