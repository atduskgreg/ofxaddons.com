class AddonSweeper < ActionController::Caching::Sweeper
  observe Addon

  def after_save(record)
    expire_page(addons_path)
    expire_page(categories_path)
    expire_page("/#{record.url}")
  end
end
