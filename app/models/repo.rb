class Repo < ActiveRecord::Base

  has_many :categorizations, inverse_of: :repo, dependent: :destroy
  has_many :categories, through: :categorizations
  has_one  :estimated_release, inverse_of: :repo, dependent: :destroy

  before_save :update_estimated_release_date

  private

  def update_estimated_release_date
    unless last_pushed_at.nil?
      release = Release.where("released_at < ?", last_pushed_at)
        .order("released_at DESC")
        .first
      self.build_estimated_release(release: release)
    end
  end

end
