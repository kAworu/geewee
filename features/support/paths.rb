module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'

    when /^the page (\d+)$/ # pagination
      root_path(:page => $1.to_i)

    when /^the blog atom feed page$/
      posts_path(:atom)

    when /^the page "([^"]*)"$/
      page_path(Page.find_by_title($1))

    when /^the post page "([^"]*)"$/
      post_path(Post.find_by_title($1))

    when /^the post "([^"]*)" atom feed page$/
      post_path(Post.find_by_title($1), :atom)

    when /^the archives page of the author "([^"]*)"$/
      archives_by_author_path(Author.find_by_name($1))

    when /^the archives page of the category "([^"]*)"$/
      archives_by_category_path(Category.find_by_display_name($1))

    when /^the archives page for the month "([^"]*)"$/
      date = DateTime.parse($1)
      archives_by_month_path(:year => date.year, :month => date.month)

    when /^the archives by month page$/
      '/archives/by_month'

    when /^the archives page of the posts tagged with "([^"]*)"$/
      archives_by_tag_path($1)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
