class CategoriesController < ApplicationController

  # before_action :set_category, only: [:show, :edit, :update, :destroy]

  # GET /repos
  def index
    @categories = Category.joins(:addons)
      .includes(:addons)
      .order("lower(repos.name) ASC")
      .all
  end

  # # GET /repos/1
  # def show
  # end

  # # GET /repos/1/edit
  # def edit
  # end

  # # POST /repos
  # def create
  #   @repo = Repo.new(repo_params)

  #   if @repo.save
  #     redirect_to @repo, notice: 'Repo was successfully created.'
  #   else
  #     render :new
  #   end
  # end

  # # PATCH/PUT /repos/1
  # def update
  #   if @repo.update(repo_params)
  #     redirect_to @repo, notice: 'Repo was successfully updated.'
  #   else
  #     render :edit
  #   end
  # end

  # # DELETE /repos/1
  # def destroy
  #   @repo.destroy
  #   redirect_to repos_url, notice: 'Repo was successfully destroyed.'
  # end

  # private
  #   # Use callbacks to share common setup or constraints between actions.
  #   def set_repo
  #     @repo = Repo.includes(:categories, :estimated_release => :release).find(params[:id])
  #   end

  #   # Only allow a trusted parameter "white list" through.
  #   def repo_params
  #     params[:repo]
  #   end
end
