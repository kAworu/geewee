Given /^the blog is configured$/ do
  Factory.create :geewee_config
end

Given /^the blog has an author named "([^"]*)"$/ do |name|
  @author = Factory.create :author, :name => name
end

Given /^the blog has a category named "([^"]*)"$/ do |name|
  @category = Factory.create :category, :display_name => name
end

Given /^the blog has a published post titled "([^"]*)" from (\d+) days ago$/ do |t, n|
  Timecop.travel(n.to_i.days.ago) do
    Factory.build(:post,
      :title    => t,
      :author   => @author,
      :category => @category).publish!
  end
end
