class Categorization < ActiveRecord::Base
  belongs_to :category, inverse_of: :categorizations
  belongs_to :addon,    inverse_of: :categorizations, foreign_key: :repo_id
end
