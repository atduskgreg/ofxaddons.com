class Addon < Repo

  # NOTE: category-related associations are in the base class
  belongs_to  :release, inverse_of: :addons, touch: true
  before_save :update_release_date

  validate :has_at_least_one_category

  private

  def has_at_least_one_category
    if type == "Addon" && categories.count == 0
      errors.add(:categories, "can't be empty")
    end
  end

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
