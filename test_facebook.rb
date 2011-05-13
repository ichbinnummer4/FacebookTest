#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
gem "sauce", ">=0.9.0"
require "sauce"
require "yaml"

# read Sauce OnDemand credentials
yml = YAML::load(File.open('ondemand.yml'))

Sauce.config do |config|
  config.browser_url = "http://www.facebook.com/"
  config.browsers = [
	["Linux", "firefox", "3.6."]#,
	# ["Windows 2003", "iexplore", "8"],
	# ["Windows 2008", "iexplore", "9."],
	# ["Windows 2003", "googlechrome", ""], # since Chrome is frequently and automatically updated, leave version empty
	# ["Windows 2003", "safari", "4."]
  ]# if it's not necessary to test all browsers, then this part can be set as a block receiver by request
  config.username = yml[:username]
  config.access_key = yml[:api_key]
end

class LoginPage
	def initialize(driver)
		@driver = driver
	end
	def login_as(user)
		@driver.instance_eval do
			open("/") # open the base URL which set as browser_url
			type("id=email", user[:email])
			type("id=pass", user[:pass])
			click("xpath=//input[@type='submit' and @value='Login']")
			wait_for_page_to_load("40000")
		end
	end
end

class FacebookTest < Sauce::TestCase

	def test_login
		puts "\nTest Login is executing..."
		LoginPage.new(page).login_as(:email => "ichbinnummer4@googlemail.com", :pass => "number4rocks")
		assert_equal("Account", page.get_text("id=navAccountLink"))
	end

	def test_change_status
		puts "\nTest Change Status is executing..."
		LoginPage.new(page).login_as(:email => "ichbinnummer4@googlemail.com", :pass => "number4rocks")
		# make sure that it stays on Home page
		page.click("xpath=//h1[@id='pageLogo']/a[@title='Home']")
		regex_time = /^(.*?)\s(.*?)\s.*/
		now = Time.now.to_s
		time_msg = "Current Date is: #{regex_time.match(now)[1]}, and Time is: #{regex_time.match(now)[2]}"
		page.type("xpath=//div[@class='uiTypeahead composerTypeahead mentionsTypeahead']/div[1]/div/textarea", "#{time_msg}")
		page.click("xpath=//div[@data-name='UIPrivacyWidget[0]']//a[@role='button']")
		page.click("xpath=//div[@data-name='UIPrivacyWidget[0]']/div/div/ul/li[2]/a/span")
		page.click("xpath=//input[@type='submit' and @value='Share']")
		# the latest posted status is always in the xpath of /li (since it's on top), otherwise there is an index after, e.g. /li[3]
		msg = page.get_text("xpath=//li/div[@class='storyContent']//span[@class='messageBody']")
		privacy = page.get_text("xpath=//li/div[@class='storyContent']//a[@class='uiTooltip uiStreamPrivacy']/span/span[@class='uiTooltipText uiTooltipNoWrap']")
		assert_equal(time_msg, msg)
		assert_equal("Friends of Friends", privacy)
	end

	def test_logout
		puts "\nTest Logout is executing..."
		LoginPage.new(page).login_as(:email => "ichbinnummer4@googlemail.com", :pass => "number4rocks")
		page.click("navAccountLink")
		page.click("xpath=//input[@type='submit' and @value='Logout']")
		page.wait_for_page_to_load("40000")
		assert page.is_element_present("xpath=//input[@type='submit' and @value='Login']")
	end

end
