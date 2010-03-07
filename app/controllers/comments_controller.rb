# only creation is allowed, deletion is only allowed to the post's author.
class CommentsController < ApplicationController

  # POST /comments
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(params[:comment])
    respond_to do |format|
      if @comment.save
        flash[:notice] = 'commentaire ajouté!'
        flash[:error]  = ''
      else
        flash[:notice] = ''
        flash[:error]  = "erreur lors de l'ajout du commentaire"
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
