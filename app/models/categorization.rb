class Categorization < ActiveRecord::Base
  belongs_to :addon,    inverse_of: :categorizations, foreign_key: :repo_id
  belongs_to :category, inverse_of: :categorizations
end
