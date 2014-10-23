class Category < ActiveRecord::Base

  has_many :categorizations, inverse_of: :category, dependent: :destroy
  has_many :repos, through: :categorizations

end
