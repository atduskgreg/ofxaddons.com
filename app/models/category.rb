class Category < ActiveRecord::Base

  has_many :addons, through: :categorizations
  has_many :categorizations, inverse_of: :category

end
