class CategoryPresenter < Presenter

  def to_s
    h.link_to(name, h.category_path(object))
  end

end
