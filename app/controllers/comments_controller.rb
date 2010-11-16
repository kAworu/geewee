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

  # POST /comments
  def create
    @comment = Post.find(params[:post_id]).comments.build(params[:comment])
    if GeeweeConfig.entry.use_recaptcha?
      @captcha_valid = verify_recaptcha(:private_key => GeeweeConfig.entry.recaptcha_private_key)
    else
      @captcha_valid = true
    end

    flash[:error] = flash[:notice] = ''
    catch :done do
      # check captcha
      unless @captcha_valid
        flash[:error] =I18n.translate('comments.invalid_captcha')
        throw :done
      end
      # check comment
      throw :done unless @comment.valid?

      if params[:options][:preview] == '1'
        flash[:notice] = I18n.translate('comments.comment_is_valid')
        @comment.created_at = Time.now # hack for the partial
      else
        @comment.save!
        flash[:notice] = I18n.translate('comments.comment_created')
      end
    end

    respond_to do |format|
      format.html do
        if @comment.new_record? # not saved in db
          flash[:comment] = @comment # save in flash for editing.
          redirect_to post_path(@comment.post, :anchor => :new_comment)
        else
          redirect_to post_path(@comment.post, :anchor => "comment_#{@comment.id}")
        end
      end
      format.js # create.js.erb
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
