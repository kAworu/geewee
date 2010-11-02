#
#   * index and show are public via HTML UI.
#   * index and show are public via Atom.
#   * all but index and show are private via JSON API.
#
class PostsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  # used for the JSON API, to include the posts count.
  JSON_OPTS = {
    :include => {
      :category => {:only => [:display_name]},
      :author   => {:only => [:name]},
      :tags     => {:only => [:name]},
    }
  }

  # require auth for all methods but show and index.
  before_filter :require_author, :except => [:index, :show]

  # GET /posts
  # GET /posts.atom
  # GET /posts.json
  def index
    respond_to do |format|
      format.atom { @posts = Post.published.first(6) } # index.atom.builder
      format.html do # index.html.haml
        params[:page] ||= 1
        @posts = Post.paginate :page => params[:page]
        redirect_to :controller => :help if @posts.count.zero?
      end
      format.json do
        opts = JSON_OPTS.merge(:except => [:intro, :body])
        render :json => Post.all.to_json(opts)
      end
    end
  end

  # GET /posts/1
  # GET /posts/1.atom
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])
    @comment = flash[:comment] || Comment.new

    respond_to do |format|
      format.html # show.html.haml
      format.atom # show.atom.builder
      format.json { render :json => @post.to_json(JSON_OPTS) }
    end
  end

  # POST /posts.json
  def create
    @post = Post.new(params[:post])
    @post.author = current_author

    respond_to do |format|
      format.json do
        if @post.save
          render :json => @post, :status => :created, :location => @post
        else
          render :json => @post.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      format.json do
        if @post.update_attributes(params[:post])
          head :ok, :location => url_for(@post)
        else
            render :json => @post.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.json { head :ok }
    end
  end

  # PUT /posts/publish/1.json
  def publish
    @post = Post.find(params[:id])

    respond_to do |format|
      format.json do
        if @post.published?
          e = [['post', 'is already published']]
          render :json => e, :status => :unprocessable_entity
        else
          @post.published = true
          @post.save!
          head :ok
        end
      end
    end
  end
end
