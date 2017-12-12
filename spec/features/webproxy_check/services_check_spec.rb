RSpec.describe "Testing main functionality ", :type => :request do

  # Need to specify environment variable 'browser' in order to open Chrome browser
  describe "web proxy services testing" do
    before :each do

      user_name = 'julie'
      user_pwd = 'Password1'
      puts "!!!!!!!!!!!!"
      x = ENV['browser']
      puts x
      browser = Capybara.current_session.driver.browser
      browser.manage.window.resize_to(1600, 800)
      @token = get_user_auth_token(user_name, user_pwd)


    end

    it "checking elasticsearch" do
      puts @token
      visit("http://webproxy.devgex.net/setcookie?token=#{@token}&u=http%3A%2F%2Fp10496.webproxy.devgex.net")
      sleep 5
      fail if (find('h1').text == "401 Authorization Required")
    end

    it "checking spark-history" do
      puts @token
      visit("http://webproxy.devgex.net/setcookie?token=#{@token}&u=http%3A%2F%2Fp10495.webproxy.devgex.net")
      sleep 5
      fail if (find('h1').text == "500 Internal Server Error")
    end


    it "checking spark-master-webui" do
      puts @token
      visit("http://webproxy.devgex.net/setcookie?token=#{@token}&u=http%3A%2F%2Fp10494.webproxy.devgex.net")
      sleep 5
      fail if (find('h1').text == "500 Internal Server Error")
    end

    it "checking hue" do
      puts @token
      visit("http://webproxy.devgex.net/setcookie?token=#{@token}&u=http%3A%2F%2Fp10493.webproxy.devgex.net")
      sleep 5
      fail if (find('h1').text == "500 Internal Server Error")
    end

    it "checking hdfs-namenode-webui" do
      puts @token
      visit("http://webproxy.devgex.net/setcookie?token=#{@token}&u=http%3A%2F%2Fp10492.webproxy.devgex.net")
      sleep 5
      fail if (find('h1').text == "500 Internal Server Error")
    end

    it "checking hadoop-resource-manager" do
      puts @token
      visit("http://webproxy.devgex.net/setcookie?token=#{@token}&u=http%3A%2F%2Fp10490.webproxy.devgex.nt")
      sleep 5
      fail if (find('h1').text == "500 Internal Server Error")
    end

  end
end