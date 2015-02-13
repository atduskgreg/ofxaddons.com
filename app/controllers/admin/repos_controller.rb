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

  def update
    raise "ajax only!" unless request.xhr?

    repo = Repo.find(repo_id)
    if repo.update_column(:type, repo_type)
      render(json: {
               status: 200,
               controller: params[:controller],
               action: params[:action],
               repo: {
                 id: repo.id,
                 type: repo.type,
                 type_title: repo.type.titleize
               }
             }, status: :ok)
    else
      render(json: {
               status: 400,
               error: repo.errors.full_messages,
               controller: params[:controller],
               action: params[:action],

             }, status: :bad_request)
    end
  end

  private

  def repo_id
    params.require(:id)
  end

  def repo_type
    params.require(:type).camelize
  end

  # dynamically define instace variables for counts of each repo type
  def set_type_counts
    vars = ""
    Repo::REPO_TYPES.each do |t|
      vars << "@#{t}_count = #{t.camelize.constantize}.count;"
    end
    eval(vars)
  end

end
