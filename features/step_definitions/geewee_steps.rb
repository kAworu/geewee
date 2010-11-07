Given /^the blog is not configured$/ do
  GeeweeConfig.destroy_all
end

Given /^the blog is configured$/ do
  Factory.create :geewee_config
end

Given /^the number of posts per page is (\d+)$/ do |n|
  GeeweeConfig.entry.update_attribute(:post_count_per_page, n.to_i)
end

Given /^the blog's title is "([^"]*)"$/ do |title|
  GeeweeConfig.entry.update_attribute(:blogtitle, title)
end

Given /^there is no posts$/ do
  Post.destroy_all
end

Given /^there is a post titled "([^"]*)"(?: by "([^"]*)")?$/ do |title, author_name|
  author = Author.find_by_name(author_name) || Factory.create(:author)
  Factory.create :post, :title => title, :author => author
end

Given /^there is (\d+) published posts?$/ do |n|
  n.to_i.times { Factory.create :post }
end

Given /^there is a page titled "([^"]*)"(?: with "([^"]*)" as body)?$/ do |title, content|
  page = Factory.build(:page, :title => title)
  page.body = content unless content.nil?
  page.save!
end

Given /^there is an author named "([^"]*)"(?: who wrote (\d+) posts?)?$/ do |name, n|
  author = Factory.create(:author, :name => name)
  n.to_i.times { Factory.create :post, :author => author } unless n.nil?
end

Then /^I should see the posts list from the author "([^"]*)"$/ do |name|
  Author.find_by_name(name).posts.each do |p|
    Then %{I should see "#{p.title}" in the content}
  end
end

# matching when we want to (not) see a list of posts. The list is given like
# "1, 2, and 3" correspond to the order of published post (started to 1).
# Example:
#   I should not see the post 1
#   I should see the posts 1 and 2
#   I should see the posts 3, 4, 5, and 42
Then /^I should (not )?see the posts? ([0-9 ,]+)(?:and (\d+))?$/ do |neg, list, last|
  (list.split(', ') << last).compact.collect!(&:to_i).each do |i|
    post = Post.published.find(:first, :offset => (i - 1))
    Then %{I should #{neg}see "#{post.title}"}
  end
end

Then /^I should complete this scenario$/ do
    pending # for ever!
end
