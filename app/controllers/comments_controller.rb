class CommentsController < ApplicationController

  # POST /comments
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(params[:comment])
    respond_to do |format|
      if @comment.save
        flash[:notice] = 'commentaire ajouté!'
      else
        flash[:error] = "erreur lors de l'ajout du commentaire"
      end
      format.html do
        redirect_to :controller => :posts,
                    :action => :show,
                    :id => @post,
                    :anchor => 'comment_form'
      end
    end
  end
end
