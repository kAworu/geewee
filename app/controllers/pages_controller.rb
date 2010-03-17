# Controller for static Page management.
#
#   * show is public via HTML UI.
#   * all are private via JSON API.
#
class PagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  # require auth for all methods but show.
  before_filter :require_author, :except => :show

  # GET /pages.json
  def index
    respond_to do |format|
      format.json { render :json => Page.all }
    end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.html.haml
      format.json { render :json => @page }
    end
  end

  # POST /pages.json
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      format.json do
        if @page.save
          render :json => @page, :status => :created, :location => @page
        else
          render :json => @page.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # PUT /pages/1.json
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      format.json do
        if @page.update_attributes(params[:page])
          head :ok
        else
          render :json => @page.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # DELETE /pages/1.json
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
