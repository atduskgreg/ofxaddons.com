namespace :assets do
  task :load_assets_gems do
    Bundler.require(:assets)
  end

  task :precompile => :load_assets_gems
end
