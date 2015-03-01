class AddCounterCacheToCategory < ActiveRecord::Migration
  def change
    add_column(:categories, :categorizations_count, :integer)
    Category.all.each do |c|
      Category.reset_counters(c.id, :categorizations)
    end
  end
end
