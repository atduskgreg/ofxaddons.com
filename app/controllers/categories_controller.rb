class CategoriesController < ApplicationController

  layout "categories"

  before_action :set_category, only: [:show]
  before_filter :set_sidebar

  # GET /repos
  def index
    @categories = Category.joins(:addons)
      .includes(:addons)
      .order("lower(categories.name) ASC, lower(repos.name) ASC")
      .all
  end

  # GET /repos/1
  def show
  end

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

  private

  def set_category
    @category = Category.joins(:addons)
      .includes(:addons)
      .find(params[:id])
  end

  def set_sidebar
    @sidebar_categories = Category.having_addons
  end

end
