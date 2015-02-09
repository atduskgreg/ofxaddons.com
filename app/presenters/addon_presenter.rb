class AddonPresenter < RepoPresenter

  def categories?
    object.categorizations.count > 0
  end

  def categories_list
    cat_names = self.categories.map {|c| c.name.downcase }
    cat_names.join(", ")
  end

  def release
    if object.release
      "~#{object.release.version}"
    else
      nil
    end
  end

end
