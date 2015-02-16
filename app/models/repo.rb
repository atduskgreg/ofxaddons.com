class Repo < ActiveRecord::Base

  REPO_TYPES = %w(addon deleted empty incomplete non_addon unsorted repo)

  # these are defined here to make sorting easier, but don't get them confused with the associations on Addon
  has_many :categorizations
  has_many :categories, -> { uniq }, through: :categorizations

  validate :type, inclusion: { in: REPO_TYPES.map(&:camelize) }

end
