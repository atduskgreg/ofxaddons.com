class ReposController < ApplicationController
  before_action :set_repo, only: [:show, :edit, :update, :destroy]

  # GET /repos
  def index
    @repos = Repo.all

    # TODO: add pagination? should consult with the crew about this
    @categories = Category.joins(:repos)
      .includes(:repos)
      .where(not_addon: false)
      .where(is_fork: false)
      .where(deleted: false)
      .order("categories.name ASC, repos.name ASC")
  end

  # GET /repos/1
  def show
    @repo = Repo.includes(:categories, :estimated_release => :release)
  end

  # GET /repos/1/edit
  def edit
  end

  # POST /repos
  def create
    @repo = Repo.new(repo_params)

    if @repo.save
      redirect_to @repo, notice: 'Repo was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /repos/1
  def update
    if @repo.update(repo_params)
      redirect_to @repo, notice: 'Repo was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /repos/1
  def destroy
    @repo.destroy
    redirect_to repos_url, notice: 'Repo was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repo
      @repo = Repo.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def repo_params
      params[:repo]
    end
end
