# Controller to manage Comments.
#
#   * create is public via HTML (http/ajax) UI.
#   * index and show comment is public via by JSON API.
#   * removing and `mark as read' comment is private via by JSON API.
#
class CommentsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  # used for the JSON API, to include the posts owning this comment.
  JSON_OPTS = {
    :include => {
      :post => {:only => [:title]},
    }
  }

  # require auth for destroy and mark_as_read methods.
  before_filter :require_author, :only => [:destroy, :next_unread]

  # GET /comments.json
  def index
    respond_to do |format|
      format.json do
        opts = JSON_OPTS.merge(:except => [:body])
        render :json => Comment.all.to_json(opts)
      end
    end
  end

  # GET /comments/1.json
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.json { render :json => @comment.to_json(JSON_OPTS) }
    end
  end

  # FIXME: i'm (very) ulgy
  # POST /comments
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(params[:comment])
    @preview = params[:option][:preview] == '1'
    @captcha = params[:option][:captcha].to_i == 42

    flash[:comment] = @comment
    respond_to do |format|
      if @captcha
        if @comment.valid?
          flash[:error]  = ''
          if @preview
            flash[:notice] = 'commentaire valide.'
            # hack for the partial
            @comment.created_at = Time.now
          else
            @comment.save!
            flash[:comment] = nil
            flash[:notice] = 'commentaire enregistré!'
          end
        else
          flash[:notice] = ''
          flash[:error]  = 'commentaire invalide'
        end
      else
        flash[:notice] = ''
        flash[:error]  = 'et ma captcha alors?'
      end
      format.html do
        redirect_to :controller => :posts,
                    :action => :show,
                    :id => @post,
                    :anchor => :new_comment
      end
      format.js
    end
  end

  # PUT /next_unread.json
  def next_unread
    @comment = Comment.unread.first

    respond_to do |format|
      format.json do
        if @comment
          @comment.update_attribute(:read, true)
          render :json => @comment.to_json(JSON_OPTS)
        else
          render :json => nil, :status => 204 # 204 - HTTPNoContent
        end
      end
    end
  end

  # DELETE /comments/1.json
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
