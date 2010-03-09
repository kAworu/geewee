module ArchivesHelper
  # define severals helpers method for creating links to the
  # ArchivesController.

  def archives_by_author_url(author=nil)
    { :controller => :archives,
      :action     => :by_author,
      :id         => author }
  end

  def archives_by_category_url(category=nil)
    { :controller => :archives,
      :action     => :by_category,
      :id         => category }
  end

  def archives_by_tag_url(tag=nil)
    { :controller => :archives,
      :action     => :by_tag,
      :id         => tag }
  end

  def archives_by_month_and_year_url(time=nil)
    url = { :controller => :archives,
            :action     => :by_month_and_year }
    if time
      url[:year]  = time.year
      url[:month] = time.month
    end
    return url
  end
end
