# some more web steps

# override to support query params such as /?page=42
Then /^(?:|I )should be on (.+)$/ do |page_name|
  uri = URI.parse(current_url)
  current_path  = uri.path
  current_path += "?#{uri.query}" unless uri.query.nil?
  current_path.should == path_to(page_name)
end

# use a similar mapping for selector as used for path.
When /^(?:|I )follow "([^"]*)" in the (.+)$/ do |link, name|
  When %{I follow "#{link}" within "#{selector_for(name)}"}
end

Then /^(?:|I )should (not )?see "([^"]*)" in the (.+)$/ do |neg, text, name|
  Then %{I should #{neg}see "#{text}" within "#{selector_for(name)}"}
end
