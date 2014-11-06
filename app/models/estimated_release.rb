class EstimatedRelease < ReleaseType

  belongs_to :release, inverse_of: :estimated_releases
  belongs_to :addon, inverse_of: :estimated_release

end
