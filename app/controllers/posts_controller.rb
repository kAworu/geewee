# Post controller, the most used.
# 
#   * index and show are public via HTML UI.
#   * index and show are public via Atom.
#   * all are private via JSON API. TODO
#
class PostsController < ApplicationController

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

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to(@post) }
        format.json  { render :json => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to(@post) }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json do
          render :json => @post.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.json { head :ok }
    end
  end

  # PUT /posts/publish/1.json
  def publish
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.published?
        # FIXME: hack
        e = [['post', 'is already published']]
        format.json do
          render :json => e, :status => :unprocessable_entity
        end
      else
        @post.published = true
        @post.save!
        format.json { head :ok }
      end
    end
  end
end
