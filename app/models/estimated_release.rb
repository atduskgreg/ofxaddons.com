class EstimatedRelease < SupportedRelease

  belongs_to :release, inverse_of: :estimated_releases
  belongs_to :repo, inverse_of: :estimated_release

end
