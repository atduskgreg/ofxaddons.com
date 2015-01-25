class Addon < Repo

  has_many :categorizations, inverse_of: :addon, dependent: :destroy, foreign_key: :repo_id
  has_many :categories, -> { uniq }, through: :categorizations
  has_one  :estimated_release, inverse_of: :addon, dependent: :destroy, foreign_key: :repo_id

  before_save :update_estimated_release_date

  private

  def update_estimated_release_date
    unless last_pushed_at.nil?
      if release = Release.where("released_at < ?", last_pushed_at)
          .order("released_at DESC")
          .first
        self.build_estimated_release(release: release)
      end
    end
  end

end
