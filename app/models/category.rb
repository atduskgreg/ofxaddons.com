class Category < ActiveRecord::Base

  has_many :addons, through: :categorizations do
    def cache_key
      [count(:updated_at),maximum(:updated_at)].map(&:to_i).join('-')
    end
  end

  has_many :categorizations, inverse_of: :category

  scope :having_addons, -> {
    select("categories.*, lower(categories.name) as sort_name")
      .joins(:addons)
      .order("lower(categories.name) ASC")
      .uniq
  }

  def to_param
    "#{id} #{name}".parameterize
  end

end
