class Repo < ActiveRecord::Base

  REPO_TYPES = %w(addon deleted empty incomplete non_addon repo unsorted)
  SORT_ATTRS = %w(description example_count full_name has_makefile name pushed_at stargazers_count)

  has_many :categories, -> { uniq }, through: :categorizations do
    def cache_key
      [count(:updated_at),maximum(:updated_at)].map(&:to_i).join('-')
    end
  end

  has_many :categorizations
  belongs_to :user, inverse_of: :repos

  validates :type, inclusion: { in: REPO_TYPES.map(&:camelize) }

  # find currently open issues on the repo whose title
  # matches one of our tags. Wish we could do this with labels
  # but it looks like only repo owners can apply labels to issues
  #
  # Current labels: ofx-incomplete, ofx-osx, ofx-win, ofx-linux
  #     (the OS-specific ones indicate a problem on that OS)
  def warning_labels
    @warning_labels ||= begin
      our_labels = ["ofx-incomplete", "ofx-osx", "ofx-win", "ofx-linux"]
      relevant_labels = []
      if issues
        JSON.parse(issues).select{|issue| issue["state"] == "open"  }.each do |issue|
          our_labels.each do |l|
            if Regexp.new(l) =~ issue["title"]
              relevant_labels << l
            end
          end
        end
      end
      relevant_labels
    end
  end

end
