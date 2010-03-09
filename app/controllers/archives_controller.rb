# Archives, display Posts filtered and/or ordered.
#
#   * all methods are public via HTML UI.
#   * none are supported by JSON API.
#
class ArchivesController < ApplicationController

  # order posts by author.
  def by_author
    if params[:id]
      @authors = [ Author.find(params[:id]) ]
    else
      @authors = Author.all
    end
  end

  # order posts by category.
  def by_category
    if params[:id]
      @categories = [ Category.find(params[:id]) ]
    else
      @categories = Category.all
    end
  end

  # order posts by tag.
  def by_tag
    if params[:id]
      @tags = [ Tag.find(params[:id]) ]
    else
      @tags = Tag.all
    end
  end

  # order posts by month
  def by_month_and_year
    if params[:month] and params[:year]
      start = Time.local(params[:year].to_i, params[:month].to_i)
      stop  = start + 1.month
      posts = Post.created_after(start).created_before(stop)
    else
      posts = Post.all
    end
    @posts = posts.group_by(&:month_and_year)
  end
end
