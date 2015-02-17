class Repo < ActiveRecord::Base

  REPO_TYPES = %w(addon deleted empty incomplete non_addon unsorted repo)

  has_many :categories, -> { uniq }, through: :categorizations
  has_many :categorizations
  belongs_to :user, inverse_of: :repos

  validate :type, inclusion: { in: REPO_TYPES.map(&:camelize) }

end
