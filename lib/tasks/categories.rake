
task :create_categories do
  Repo.transaction do
    Repo.all.each do |r|
      case
      when r.deleted       then r.type = "Deleted";  r.save!
      when r.not_addon     then r.type = "NonAddon"; r.save!
      when !!r.category_id
        addon = r.becomes!(Addon)
        addon.categories << Category.find(addon.category_id)
        addon.save!
      end
    end
  end
end
