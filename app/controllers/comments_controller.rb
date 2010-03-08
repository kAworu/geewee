# only creation is allowed, deletion is only allowed to the post's author.
class CommentsController < ApplicationController

  # POST /comments
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(params[:comment])
    @preview = params[:option][:preview] == '1'
    respond_to do |format|
      if @comment.valid?
        flash[:error]  = ''
        if @preview
          flash[:notice] = 'commentaire valide.'
          # hack for the partial
          @comment.created_at = Time.now
        else
          @comment.save!
          flash[:notice] = 'commentaire enregistré!'
        end
      else
        flash[:notice] = ''
        flash[:error]  = 'commentaire invalide'
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
