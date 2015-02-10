class Admin::ReposController < Admin::ApplicationController

  before_action :set_type_counts

  def index
    type = case params[:type]
           when "addon"
             Addon
           when "deleted"
             Deleted
           when "empty"
             Empty
           when "incomplete"
             Incomplete
           when "non_addon"
           else
             Unsorted
           end

    @repos = type.order('repos.stargazers_count, repos.example_count, repos.pushed_at DESC, lower(repos.name) ASC')
  end

  private

  # dynamically define instace variables for counts of each repo type
  def set_type_counts
    vars = ""
    Repo::REPO_TYPES.each do |t|
      vars << "@#{t}_count = #{t.camelize.constantize}.count;"
    end
    eval(vars)
  end

end
