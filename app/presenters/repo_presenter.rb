class RepoPresenter < Presenter

  def categories?
    object.categorizations.count > 0
  end

  def categories_list
    cat_names = self.categories.map {|c| c.name.downcase }
    cat_names.join(", ")
  end

  def estimated_release
    object.estimated_release.release.version
  end

  def example_count
    object.example_count || 0
  end

  def examples?
    !!object.example_count && object.example_count > 0
  end

  def features?
    makefile? || examples?
  end

  def followers?
    !!object.followers && object.followers > 0
  end

  def fresher_forks
    object.fresher_forks.sort_by(&:last_pushed_at).reverse
  end

  def github_url
    "http://github.com/#{ object.github_slug }"
  end

  def last_pushed_at(format)
    object.last_pushed_at.strftime(format)
  end

  def makefile?
    !!object.has_makefile
  end

  # TODO: delete me when owner is normalized
  def owner_avatar?
    !owner_avatar.blank?
  end

  def thumbnail?
    !!object.has_thumbnail
  end

  def warning_labels?
    !warning_labels.blank?
  end

  # TODO: refactor this? lifted straight from the sinatra app
  #       seems like these ought to be procomputed, maybe normalized
  #
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
      if object.issues
        object.issues.select{|issue| issue["state"] == "open"  }.each do |issue|
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
