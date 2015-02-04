namespace :assets do
  task :load_assets_group do
    Bundler.require(:assets)
  end
  task :precompile => :load_assets_group
end
