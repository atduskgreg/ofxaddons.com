class Categorization < ActiveRecord::Base
  belongs_to :addon,    inverse_of: :categorizations, touch: true, foreign_key: :repo_id
  belongs_to :category, inverse_of: :categorizations, touch: true, counter_cache: true
end
