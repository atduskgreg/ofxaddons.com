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

    @repos = type.order('repos.stargazers_count DESC, repos.example_count DESC, repos.pushed_at DESC, lower(repos.name) ASC')

    # collections array of categories for generating the categories modal form
    @categories = Category.order("lower(categories.name) ASC").all.map {|c| [c.name, c.id]}

    # HACK: if I put Addon.new() here then the form submit method is
    #       forced to POST by the rails internals. We'll replace the
    #       guts of this object before we post back to the server.
    @placeholder_repo = Repo.new
  end

  def update
    raise "ajax only!" unless request.xhr?

    repo = Repo.find(repo_id)
    repo.type = repo_type
    repo.category_ids = repo_category_ids
    if repo.save
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

  def repo_category_ids
    repo_params[:category_ids]
  end

  def repo_id
    params.require(:id)
  end

  def repo_params
    params.require(:repo)
  end

  def repo_type
    repo_params[:type].camelize
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
