class CategoryPresenter < Presenter

  def anchor_link
    h.link_to(object.name, h.categories_path(anchor: object.name.parameterize))
  end

  def anchor_tag
    h.content_tag(:a, "", name: object.name.parameterize)
  end

  def to_s
    h.link_to(object.name, category_path(object))
  end

end
