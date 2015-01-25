class AddonPresenter < Presenter

  def categories?
    object.categorizations.count > 0
  end

  def categories_list
    cat_names = self.categories.map {|c| c.name.downcase }
    cat_names.join(", ")
  end

  def estimated_release
    if object.estimated_release
      "(~#{object.estimated_release.release.version})"
    else
      nil
    end
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

  # TODO: fix this link once users are normalized
  def owner
    # h.link_to(object.owner) do
      "#{ owner_avatar } #{ object.owner }".html_safe
    # end
  end

  def owner_avatar
    if owner_avatar?
      h.image_tag(nil, class:"userIcon lazy", data:{ src:"#{ object.owner_avatar }&amp;s=16" }, width: 16)
    else
      h.image_tag("default-gravatar-small.png", class: "userIcon", width: 16)
    end
  end

  # TODO: delete me when owner is normalized
  def owner_avatar?
    !object.owner_avatar.blank?
  end

  def thumbnail
    if thumbnail?
      url = "https://raw.github.com/#{github_slug}/master/ofxaddons_thumbnail.png"
      h.image_tag("", class:"lazy addon-thumb", data:{ src: url }, width:"270px")
    end
  end

  def thumbnail?
    !!object.has_thumbnail
  end

  def warning_labels?
    !warning_labels.blank?
  end

  def watchers?
    !!object.watchers_count && object.watchers_count > 0
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
        JSON.parse(object.issues).select{|issue| issue["state"] == "open"  }.each do |issue|
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
