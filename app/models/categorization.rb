class Categorization < ActiveRecord::Base
  belongs_to :category, inverse_of: :categorizations
  belongs_to :repo,     inverse_of: :categorizations
end
