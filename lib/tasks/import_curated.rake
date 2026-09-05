# Ingests a JSON file of externally-crawled/curated addon data and applies
# it conservatively:
#
#   - A repo already in the DB (matched by full_name) only has its
#     crawl-derived columns refreshed (description, pushed_at,
#     stargazers_count, forks_count, has_makefile,
#     has_correct_folder_structure, has_thumbnail) - type and
#     categorizations are never touched, since those are this site's own
#     curation.
#   - A repo not yet in the DB is inserted as Addon (if at least one of its
#     categories already exists here) or Unsorted (uncategorized, same as
#     this site's own crawler would produce for something new) otherwise.
#   - A category named in the import that doesn't already exist here is
#     skipped by default (never silently added to this site's taxonomy) -
#     pass ALLOW_NEW_CATEGORIES=1 to create missing categories instead.
#
# Usage:
#   bin/rake import:curated[path/to/import.json]
#   ALLOW_NEW_CATEGORIES=1 bin/rake import:curated[path/to/import.json]
#
# Expected JSON shape:
#   {
#     "repos": [
#       {
#         "full_name": "owner/repo", "name": "repo", "description": "...",
#         "pushed_at": "2026-01-01T00:00:00Z", "stargazers_count": 12,
#         "forks_count": 3, "has_makefile": true,
#         "has_correct_folder_structure": true, "has_thumbnail": false,
#         "categories": ["Sound", "Utilities"],
#         "user": {"login": "owner", "avatar_url": "https://..."}
#       }
#     ]
#   }
namespace :import do
  desc "Import externally-crawled/curated addon data conservatively (see comment above)"
  task :curated, [:path] => :environment do |_t, args|
    path = args[:path] || ENV["IMPORT_PATH"]
    raise "Usage: bin/rake import:curated[path/to/import.json]" if path.blank?
    raise "File not found: #{path}" unless File.exist?(path)

    allow_new_categories = ENV["ALLOW_NEW_CATEGORIES"] == "1"
    data = JSON.parse(File.read(path))

    updated = 0
    inserted_addon = 0
    inserted_unsorted = 0
    skipped_categories = Set.new

    Repo.transaction do
      (data["repos"] || []).each do |item|
        full_name = item["full_name"]
        next if full_name.blank?

        repo = Repo.where(full_name: full_name).first

        if repo
          repo.description = item["description"] if item["description"].present?
          repo.pushed_at = item["pushed_at"] if item["pushed_at"].present?
          repo.stargazers_count = item["stargazers_count"] if item["stargazers_count"]
          repo.forks_count = item["forks_count"] if item["forks_count"]
          repo.has_makefile = item["has_makefile"] unless item["has_makefile"].nil?
          repo.has_correct_folder_structure = item["has_correct_folder_structure"] unless item["has_correct_folder_structure"].nil?
          repo.has_thumbnail = item["has_thumbnail"] unless item["has_thumbnail"].nil?
          repo.save!
          updated += 1
          next
        end

        wanted_categories = []
        (item["categories"] || []).each do |name|
          cat = Category.where("lower(name) = ?", name.downcase).first
          cat = Category.create!(name: name) if cat.nil? && allow_new_categories
          if cat
            wanted_categories << cat
          else
            skipped_categories << name
          end
        end

        user = nil
        if item["user"] && item["user"]["login"].present?
          login = item["user"]["login"]
          user = User.find_provider_login("github", login)
          if user.nil?
            user = User.new(provider: "github", login: login, avatar_url: item["user"]["avatar_url"])
            user.save!
          end
        end

        repo = Repo.new(
          name: item["name"],
          description: item["description"],
          pushed_at: item["pushed_at"],
          full_name: full_name,
          has_makefile: item["has_makefile"],
          has_correct_folder_structure: item["has_correct_folder_structure"],
          has_thumbnail: item["has_thumbnail"],
          stargazers_count: item["stargazers_count"] || 0,
          forks_count: item["forks_count"] || 0,
          user: user,
          type: wanted_categories.any? ? "Addon" : "Unsorted"
        )
        repo.save!

        wanted_categories.each do |cat|
          Categorization.create!(category: cat, addon: repo)
        end

        if wanted_categories.any?
          inserted_addon += 1
        else
          inserted_unsorted += 1
        end
      end
    end

    puts "Updated: #{updated}"
    puts "Inserted as Addon: #{inserted_addon}"
    puts "Inserted as Unsorted: #{inserted_unsorted}"
    if skipped_categories.any?
      puts "Skipped categories (not found - pass ALLOW_NEW_CATEGORIES=1 to create them): #{skipped_categories.to_a.join(', ')}"
    end
  end
end
