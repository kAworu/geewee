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
end
