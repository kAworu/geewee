# only creation is allowed, deletion is only allowed to the post's author.
class CommentsController < ApplicationController

  # FIXME: i'm ulgy
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
end
