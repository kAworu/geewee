# some more web steps
Then /^I should be redirected to (.+)$/ do |location|
  @response.should redirect_to path_to location
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  uri = URI.parse(current_url)
  current_path  = uri.path
  current_path += "?#{uri.query}" unless uri.query.nil?
  current_path.should == path_to(page_name)
end
