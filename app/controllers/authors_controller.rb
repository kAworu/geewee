#
#   * all methods are private via JSON API.
#
class AuthorsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  # require auth for all methods
  before_filter :require_author

  # GET /authors.json
  def index
    respond_to do |format|
      format.json { render :json => current_author.to_json }
    end
  end

  # PUT /authors/1.json
  def update
    @author = Author.find(params[:id])
    render :json => [['GTFO']], :status => :unauthorized and return if @author != current_author

    respond_to do |format|
      if @author.update_attributes(params[:author])
        format.json { head :ok }
      else
        format.json do
          render :json => @author.errors, :status => :unprocessable_entity
        end
      end
    end
  end
end
