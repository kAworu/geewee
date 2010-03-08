class ArchivesController < ApplicationController
  # group posts by author
  def by_author
    if params[:id]
      @authors = [ Author.find(params[:id]) ]
    else
      @authors = Author.find(:all)
    end
  end

  # group posts by category
  def by_category
    if params[:id]
      @categories = [ Category.find(params[:id]) ]
    else
      @categories = Category.find(:all)
    end
  end

  # group posts by tag
  def by_tag
    if params[:id]
      @tags = [ Tag.find(params[:id]) ]
    else
      @tags = Tag.find(:all)
    end
  end
end
