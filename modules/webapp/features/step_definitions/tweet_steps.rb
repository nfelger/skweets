Given /^10 tweets have been processed$/ do
  10.times do |n|
    Tweet.create(:id => n, :time_posted => Time.now - n)
  end
end

When /^I visit "([^\"]*)"$/ do |url|
  visit url
end

Then /^I want to see 10 tweets$/ do
  num = 10
  page.should have_selector("li.tweet", :count => num)
end
