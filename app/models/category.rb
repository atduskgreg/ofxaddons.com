class Category < ActiveRecord::Base

  has_many :categorizations, inverse_of: :category
  has_many :addons, through: :categorizations

end
