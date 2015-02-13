class Repo < ActiveRecord::Base

  REPO_TYPES = %w(addon deleted empty incomplete non_addon unsorted repo)

  validate :type, inclusion: { in: REPO_TYPES.map(&:camelize) }

end
