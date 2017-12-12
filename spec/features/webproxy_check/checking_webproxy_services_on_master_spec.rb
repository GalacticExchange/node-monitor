RSpec.describe "Testing main functionality ", :type => :request do
  # gex_env=main browser=chrome user_name=kennedi-abernathy cluster_uid= rspec spec/features/webproxy_check/checking_webproxy_services_on_master_spec.rb
  require 'uri'
  describe "checking webproxy services on master" do

    before(:all) do
      browser = Capybara.current_session.driver.browser
      browser.manage.window.resize_to(2400, 1600)
      @user_name = ENV['user_name'] || 'kennedi-abernathy'
      @user_pwd = ENV['user_pwd'] || 'Password1'
      @cluster_uid = ENV['cluster_uid'] || '3171849536517029'

    end

    after :each do
      sign_out
    end


    it "checking ELASTIC web ui connection" do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      search_visualize_tab.click
      find('#sv_groups_dropdown').find('[alt="Down"]').click
      find('p', :text => 'master').click

      elastic_port = find('#elastic_block').find('[data-div="port"]').text
      puts elastic_port

      expected_url = "http://p#{elastic_port}.webproxy.devgex.net/"

      find('#elastic_block').connect_button.click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url

      i = 0

      if actual_url == expected_url
        if first('body pre') != nil
          puts "Elastic web ui connection works"
        elsif first('center h1').text.should == "401 Authorization Required"
          puts "ELASTIC: 401 Authorization Required"
          i = 1
        else
          puts "Elastic web ui connection does NOT work"
          i = 2
        end
      else
        puts "Elastic: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} "
        i = 3
      end

    page.driver.browser.close
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      puts URI.parse(current_url).to_s
      page.driver.browser.navigate.refresh
      sleep 5
      stats_tab.click
      fail "ELASTIC: 401 Authorization Required" if i == 1
      fail "Elastic web ui connection does NOT work" if i == 2
      fail "Elastic: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if i == 3
    end


    it 'checking HDFS resource manager web ui connection' do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      big_data_tab.click
      find('#sv_groups_dropdown').find('[alt="Down"]').click
      find('p', :text => 'master').click

      hdfs_port = find('#hadoop_resource_manager_block').find('[data-div="port"]').text
      puts hdfs_port

      expected_url = "http://p#{hdfs_port}.webproxy.devgex.net/cluster"
      find('#hadoop_resource_manager_block').connect_button.click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url

      i = 0
      if actual_url == expected_url
        if first('#logo') != nil
          puts "HDFS resource manager web ui  connection work"
        end
      else
        puts "HDFS resource manager: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} "
        i = 1

      end

      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      puts URI.parse(current_url).to_s
      page.driver.browser.navigate.refresh
      sleep 5
      stats_tab.click
      fail "HDFS resource manager: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if i == 1

    end


    it 'checking HDFS  WEB UI connection' do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      big_data_tab.click
      find('#sv_groups_dropdown').find('[alt="Down"]').click
      find('p', :text => 'master').click

      hdfs_nodemane_port = find('#hdfs_namenode_webui_block').find('[data-div="port"]').text
      puts hdfs_nodemane_port

      expected_url = "http://p#{hdfs_nodemane_port}.webproxy.devgex.net/dfshealth.html#tab-overview"
      find('#hdfs_namenode_webui_block').connect_button.click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url
      i = 0

      if actual_url == expected_url
        if first('#tab-overview') != nil
          puts "HDFS WEB UI connection work"
        end
      else
        puts "HDFS WEB UI: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} "
        i = 1
      end

      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      puts URI.parse(current_url).to_s
      page.driver.browser.navigate.refresh
      sleep 5
      stats_tab.click
      fail "HDFS WEB UI: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if i == 1

    end


    it 'checking HUE connection' do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      big_data_tab.click
      find('#sv_groups_dropdown').find('[alt="Down"]').click
      find('p', :text => 'master').click

      hue_port = find('#hue_block').find('[data-div="port"]').text
      puts hue_port

      expected_url = "http://p#{hue_port}.webproxy.devgex.net/"
      find('#hue_block').connect_button.click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url

      i = 0
      if actual_url == expected_url
        if find('#jHueTourModal') != nil
          find('#jHueTourModalClose').click
          first('.sidebar-nav') != nil
          puts "Hue web ui connection works"
        elsif find('#jHueTourModal') == nil
          page.driver.browser.close if find('.sidebar-nav') == nil
          puts "Hue web ui connection works"
        else
          puts 'Hue web ui connection does not work'
          i = 1
        end
      else
        puts "HUE: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} "
        i = 2

      end

      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      puts URI.parse(current_url).to_s
      page.driver.browser.navigate.refresh
      sleep 5
      stats_tab.click
      fail 'Hue web ui connection does not work' if i == 1
      fail "HUE: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if i == 2


    end

    it 'checking Spark WEB UI connection' do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      big_data_tab.click
      find('#sv_groups_dropdown').find('[alt="Down"]').click
      find('p', :text => 'master').click

      spark_port = find('#spark_master_webui_block').find('[data-div="port"]').text
      puts spark_port

      expected_url = "http://p#{spark_port}.webproxy.devgex.net/"
      find('#spark_master_webui_block').connect_button.click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url

      i = 0
      if actual_url == expected_url
        if first('#tab-overview') != nil
          puts "SPARK WEB UI connection work"
        end
      else
        puts "SPARK WEB UI: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} "
        i = 1
      end

      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      puts URI.parse(current_url).to_s
      page.driver.browser.navigate.refresh
      sleep 5
      stats_tab.click
      fail puts "SPARK WEB UI: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if i == 1

    end


    it 'checking Spark history connection' do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      big_data_tab.click
      find('#sv_groups_dropdown').find('[alt="Down"]').click
      find('p', :text => 'master').click

      spark_history_port = find('#spark_history_block').find('[data-div="port"]').text
      puts spark_history_port

      expected_url = "http://p#{spark_history_port}.webproxy.devgex.net/"

      find('#spark_history_block').connect_button.click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url

      i = 0
      if actual_url == expected_url
        if first('.container-fluid') != nil
          puts "SPARK history connection work"
        end
      else
        puts "SPARK history: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} "
        i = 1

      end
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      puts URI.parse(current_url).to_s
      page.driver.browser.navigate.refresh
      sleep 5
      stats_tab.click
      fail "SPARK history: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if i == 1

    end


    it "checking KUDU web ui connection" do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      big_data_tab.click
      find('#sv_groups_dropdown').find('[alt="Down"]').click
      find('p', :text => 'master').click

       kudu_port = find('#kudu_block').find('[data-div="port"]').text
      puts kudu_port

      expected_url = "http://p#{kudu_port}.webproxy.devgex.net/"

      find('#kudu_block').connect_button.click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url

      i = 0

      if actual_url == expected_url
        if first('body pre') =~ /kudu.*\srevision.*\sbuild type.*.*\sbuilt by .*/
          puts "KUDU web ui connection works"
        elsif first('center h1').text.should == "401 Authorization Required"
          puts "KUDU: 401 Authorization Required"
          i = 1
        else
          puts "KUDU web ui connection does NOT work properly"
          i = 2
        end
      else
        puts "KUDU: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} "
        i = 3
      end
      page.driver.browser.close
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      puts URI.parse(current_url).to_s
      page.driver.browser.navigate.refresh
      sleep 5
      stats_tab.click

      fail "KUDU web ui connection does NOT work" if i == 2
      fail "KUDU: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if i == 3
      fail "KUDU: 401 Authorization Required" if i == 1
    end

    it "checking IMPALA web ui connection" do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      big_data_tab.click
      find('#sv_groups_dropdown').find('[alt="Down"]').click
      find('p', :text => 'master').click

      impala_port = find('#impala_block').find('[data-div="port"]').text
      puts impala_port

      expected_url = "http://p#{impala_port}.webproxy.devgex.net/"

      find('#impala_block').connect_button.click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url

      i = 0

      if actual_url == expected_url
        if first('body pre') =~ /kudu.*\srevision.*\sbuild type.*.*\sbuilt by .*/
          puts "IMPALA web ui connection works"
        elsif first('center h1').text.should == "401 Authorization Required"
          puts "IMPALA: 401 Authorization Required"
          i = 1
        else
          puts "IMPALA web ui connection does NOT work properly"
          i = 2
        end
      else
        puts "IMPALA: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} "
        i = 3
      end
      page.driver.browser.close
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      puts URI.parse(current_url).to_s
      page.driver.browser.navigate.refresh
      sleep 5
      stats_tab.click

      fail "IMPALA: 401 Authorization Required" if i == 1
      fail "IMPALA web ui connection does NOT work" if i == 2
      fail "IMPALA: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if i == 3

    end


    it "checking SSH connection" do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      big_data_tab.click
      find('#sv_groups_dropdown').find('[alt="Down"]').click
      find('p', :text => 'master').click

      ssh_port = find('#ssh_block').find('[data-div="port"]').text
      puts "ssh_port"
      puts ssh_port
      token = api_auth(@user_name, @user_pwd)
      puts token
      check_ssh_on_aws_node(@user_name, token, ssh_port, 'master')

    end


  end
end