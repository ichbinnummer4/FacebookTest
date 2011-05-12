#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
gem "sauce", ">=0.9.0"
require "sauce"

Sauce.config do |config|
  config.browser_url = "http://www.facebook.com/"
  config.browsers = [
	["Linux", "firefox", "3.6."],
	["Windows 2003", "iexplore", "8"]
  ]
end

class FacebookTest < Sauce::TestCase
	def test_login
		page.open("/")
		page.type("id=email", "ichbinnummer4@googlemail.com")
		page.type("id=pass", "number4rocks")
		page.click("xpath=//input[@type='submit' and @value='Login']")
		page.wait_for_page_to_load("30000")
		assert page.is_text_present("Account")
		# page.verifyText("navAccountLink", "Account")
		# page.verifyTextPresent("Account")
		# begin
			# assert page.is_text_present("asdfkla")
		# rescue Test::Unit::AssertionFailedError
			# @verification_errors << $!
		# end
    end

	# ensure that it stays on Home page
	#~ page.click("xpath=//h1[@id='pageLogo']/a[@title='Home']")

    def test_change_status
		page.open("/")
		page.type("id=email", "ichbinnummer4@googlemail.com")
		page.type("id=pass", "number4rocks")
		page.click("xpath=//input[@type='submit' and @value='Login']")
		page.wait_for_page_to_load("30000")
		assert page.is_text_present("Account")
		page.click("xpath=//h1[@id='pageLogo']/a[@title='Home']")
		regex_time = /^(.*?)\s(.*?)\s.*/
		time_msg = "Current Date is: #{regex_time.match(Time.now.to_s)[1]}, and Time is: #{regex_time.match(Time.now.to_s)[2]}"
		# page.type "xhpc_message_text", "#{time_msg}"
		page.type("xpath=//div[@class='uiTypeahead composerTypeahead mentionsTypeahead']/div[1]/div/textarea", "#{time_msg}")
		page.click("xpath=//div[@data-name='UIPrivacyWidget[0]']//a[@role='button']")
		page.click("xpath=//div[@data-name='UIPrivacyWidget[0]']/div/div/ul/li[2]/a/span")
		page.click("xpath=//input[@type='submit' and @value='Share']")
    end

    def test_logout
		page.open("/")
		page.type("id=email", "ichbinnummer4@googlemail.com")
		page.type("id=pass", "number4rocks")
		page.click("xpath=//input[@type='submit' and @value='Login']")
		page.wait_for_page_to_load("30000")
		assert page.is_text_present("Account")
		page.click("navAccountLink")
		page.click("xpath=//input[@type='submit' and @value='Logout']")
		page.wait_for_page_to_load "30000"
		sleep 15
    end
end
