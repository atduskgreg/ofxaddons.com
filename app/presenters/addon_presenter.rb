class AddonPresenter < RepoPresenter

  def categories?
    object.categorizations.count > 0
  end

  def categories_list
    cats = []
    self.categories.each do |c|
      cats << h.link_to(c.name, h.category_path(c))
    end
    h.safe_join(cats, ", ")
  end

  def release
    if object.release
      "~#{object.release.version}"
    else
      nil
    end
  end

end
