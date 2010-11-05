Given /^The blog is not configured$/ do
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

Given /^there is a post titled "([^"]*)"(?: from (\d+) days? ago)?$/ do |t, n|
  jetlag = (n.try(:to_i) || 0).days.ago
  Timecop.travel(jetlag) do
    Factory.build(:post, :title => t).publish!
  end
end

Then /^I should be redirected to "([^"]*)"$/ do |location|
  response.should redirect_to path_to location
end
