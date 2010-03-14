# Controller to manage Categories.
#
#   * all methods are private via JSON API.
#
class CategoriesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  # used for the JSON API, to include the posts count.
  JSON_OPTS = {
    :include => {
      :posts => {:only => [:id]}
    }
  }


  # require auth for all methods.
  before_filter :require_author

  # GET /categories.json
  def index
    @categories = Category.all
    respond_to do |format|
      format.json { render :json => @categories.to_json(JSON_OPTS) }
    end
  end

  # GET /categories/1.json
  def show
    @category = Category.find(params[:id])
    respond_to do |format|
      format.json { render :json => @category.to_json(JSON_OPTS) }
    end
  end

  # POST /categories.json
  def create
    @category = Category.new(params[:category])
    respond_to do |format|
      if @category.save
        format.json do
          render :json => @category.to_json(JSON_OPTS), :status => :created
        end
      else
        format.json do
          render :json => @category.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # PUT /categories/1.json
  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.json { head :ok }
      else
        format.json do
          render :json => @category.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # DELETE /categories/1.json
  def destroy
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.destroy
        format.json { head :ok }
      else
        format.json do
          # FIXME: hack!
          render :json => [['posts', 'is not empty']], :status => :unprocessable_entity
        end
      end
    end
  end
end
