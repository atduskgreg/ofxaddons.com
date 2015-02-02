class Addon < Repo

  has_many   :categorizations, inverse_of: :addon, foreign_key: :repo_id
  has_many   :categories, -> { uniq }, through: :categorizations
  belongs_to :release, inverse_of: :addons

  before_save :update_release_date

  private

  def update_release_date
    unless pushed_at.nil?
      if release = Release.where("released_at < ?", pushed_at)
          .order("released_at DESC")
          .first
        self.release = release
      end
    end
  end

end
