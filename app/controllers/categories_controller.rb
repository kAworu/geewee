# Controller to manage Categories.
#
#   * all methods are private via JSON API. TODO
#
class CategoriesController < ApplicationController

  # GET /categories.json
  def index
    @categories = Category.all
    respond_to do |format|
      format.json { render :json => @categories }
    end
  end

  # POST /categories.json
  def create
    @category = Category.new(params[:category])
    respond_to do |format|
      if @category.save
        format.json { render :json => @category, :status => :created }
      else
        format.json { render :json => @category.errors, :status => :error }
      end
    end
  end
end
