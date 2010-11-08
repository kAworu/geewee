# Archives, display Posts filtered and/or ordered.
#
#   * all methods are public via HTML UI.
#   * none are supported by JSON API.
#
class ArchivesController < ApplicationController

  # order posts by author.
  def by_author
    if params[:id]
      @authors = [Author.find(params[:id])]
    else
      @authors = Author.all
    end
  end

  # order posts by category.
  def by_category
    if params[:id]
      @categories = [Category.find(params[:id])]
    else
      @categories = Category.all
    end
  end

  # order posts by tag.
  def by_tag
    if params[:id]
      @tags = [Tag.find_by_name(params[:id])]
    else
      @tags = Post.tag_counts
    end
  end

  # order posts by month
  def by_month
    y, m = params[:year], params[:month]
    if y and m
      posts = Post.from_month_of_year(y.to_i, m.to_i)
    else
      posts = Post.published
    end
    @posts = posts.group_by(&:month_of_the_year)
  end
end
