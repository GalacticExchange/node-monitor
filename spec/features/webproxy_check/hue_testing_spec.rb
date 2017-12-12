
RSpec.describe "Testing main functionality ", :type => :request do

  # Need to specify environment variable 'browser' in order to open Chrome browser
  describe "web proxy testing" do
    before :each do

      puts "!!!!!!!!!!!!"
      browser = Capybara.current_session.driver.browser
      browser.manage.window.resize_to(1600, 800)
    end

    it "current user login in ClusterGX" do
      x = ENV['browser']
      puts x


      visit('http://www.google.com')

      visit('http://p10079.webproxy.devgex.net/')
      sleep 3
      url1 = URI.parse(current_url).to_s

      puts url1
      if url1 =~ /.*api.devgex.net.*signin.*/
      else
        fail "!Hue webproxy link is not redirect user to  login page!"
      end

      fill_in 'user_login', :with => 'nelson-gulgowski'
      fill_in 'user_password', :with => 'Password1'
      login_button.click

      url = URI.parse(current_url).to_s
      puts url

      if url =~ /.*webproxy.devgex.net.*/
      else
        "!Redirecting on the Hue page by webproxy did not materialize!"
      end
      puts "COOKIES"
      session = Capybara.current_session
      puts session.driver.browser.manage.all_cookies

    end

    it "someone else login in ClusterGX " do

      x = ENV['browser']
      puts x
      puts "COOKIES1"
      session = Capybara.current_session
      puts session.driver.browser.manage.all_cookies
      page.driver.browser.manage.delete_cookie('token')
      page.driver.browser.manage.delete_cookie('sessionid')
      page.driver.browser.manage.delete_cookie('__utmc')
      page.driver.browser.manage.delete_cookie('__utmb')
      page.driver.browser.manage.delete_cookie('__utma')
      page.driver.browser.manage.delete_cookie('__utmt')
      page.driver.browser.manage.delete_cookie('__utma')
      page.driver.browser.manage.delete_cookie('__utmz')

      puts "COOKIES2"
      session = Capybara.current_session
      puts session.driver.browser.manage.all_cookies

      visit('http://www.google.com')
      sleep 3
      visit('http://p10079.webproxy.devgex.net/')
      sleep 3
      url1 = URI.parse(current_url).to_s
      puts url1
      if url1 =~ /.*api.devgex.net.*signin.*/
      else
        fail "!Hue webproxy link is not redirect user to login page!"
      end


      fill_in 'user_login', :with => 'eloy-leannon'
      fill_in 'user_password', :with => 'Password1'
      login_button.click

      text = find('h1').text
      puts text

      if  text == "Authorization Required"
      else
        "!User can visit someone else's Hue page "
      end

    end

  end
end
