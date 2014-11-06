class CategoryPresenter < Presenter

  def to_s
    h.link_to(object.name, category_path(object))
  end

end
