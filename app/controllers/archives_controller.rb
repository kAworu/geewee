class ArchivesController < ApplicationController
  # group posts by author
  def by_author
    if author = Author.find(params[:id])
      @authors = [author]
    else
      @authors = Author.find(:all)
    end
  end

  # group posts by category
  def by_category
    if category = Category.find(params[:id])
      @categories = [category]
    else
      @categories = Category.find(:all)
    end
  end

  # group posts by tag
  def by_tag
    if tag = Tag.find(params[:id])
      @tags = [tag]
    else
      @tags = Tag.find(:all)
    end
  end
end
