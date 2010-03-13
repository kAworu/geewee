# Post controller, the most used.
# 
#   * index and show are public via HTML UI.
#   * index and show are public via Atom.
#   * all are private via JSON API. TODO
#
class PostsController < ApplicationController
  # require auth for all methods.
  before_filter :require_author, :except => [:index, :show]

  # GET /posts
  # GET /posts.atom
  # GET /posts.json
  def index
    respond_to do |format|
      format.html { @posts = Post.published } # index.html.haml
      format.atom { @posts = Post.published } # index.atom.builder
      format.json do
        render :json => Post.find(:all, :select => 'id, title, published')
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
      format.json { render :json => @post }
    end
  end

  # POST /posts.json
  def create
    @post = Post.new(params[:post])

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
          head :ok
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
          e = [['post', 'is already published']] # FIXME: hack
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
