# gex_env=main browser=chrome user_name=kennedi-abernathy cluster_name=name cluster_uid=uid node_name=name node_uid=uid rspec spec/features/nodes/aws/core_node/checking_sevices_on_aws_core_node_spec.rb
RSpec.describe "Testing main functionality ", :type => :request do
  require 'uri'
  describe "nodes hue and  hadoop services" do

    before(:all) do

      puts 'VERIFY NODE HADOOP AND HUE SERVICES'
      browser = Capybara.current_session.driver.browser
      browser.manage.window.resize_to(2400, 1600)

      @user_name = ENV['user_name'] || 'kennedi-abernathy' #'night-tester'
      @user_pwd = ENV['user_pwd'] || 'Password1'

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_name = ENV['cluster_name'] || @user_data['aws']['cluster_name']
      @cluster_id = ENV['cluster_uid'] || @user_data['aws']["#{@cluster_name}_data"]['cluster_id']
      @cluster_uid = ENV['cluster_uid'] || @user_data['aws']["#{@cluster_name}_data"]['cluster_uid']
      @node_name = ENV['node_name'] || @user_data['aws']["#{@cluster_name}_data"]['node_name']
      @node_uid = ENV['node_uid'] || @user_data['aws']["#{@cluster_name}_data"]["#{@node_name}_data"]['node_uid']
      puts @cluster_name, @cluster_uid, @node_name, @node_uid

      @tests_passed = []
      @tests_failed = {}


    end

    after(:each) do |example|
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      stats_tab.click
      sign_out

      if example.exception != nil
        test_exception = example.exception.to_s
        @tests_failed.merge!(example.description => test_exception)
      else
        @tests_passed << example.description
      end
    end

    after(:all) do
      if @tests_failed.size != 0
        passed = false
        File.open('/work/tests/data/tests_result/failed_test.json', 'w') { |f| f << JSON.pretty_generate(@tests_failed) }
      else
        passed = true
      end

      slack_msg_verify_node_services(passed, @user_name, 'AWS CORE', @cluster_name, @cluster_id, @cluster_uid, @node_name, @node_uid, @tests_passed, @tests_failed)
    end


    it 'checking hue web ui connection' do

      visit('http://hub.devgex.net:8080/signin')
      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click

      select_node(@node_uid).click
      sleep 3

      hue_node_container(@node_name).click
      hue_port = get_port('hue')


      expected_url = "http://p#{hue_port}.webproxy.devgex.net/accounts/login/?username=#{@user_name}"
      puts "expected url"
      puts expected_url
      connect_button('hue').click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 15
      page.driver.browser.navigate.refresh
      sleep 5

      actual_url = URI.parse(current_url).to_s
      puts "actual  url"
      puts actual_url

      status = check_service_page(actual_url, expected_url, aws_node_hue_page, 'hue')

      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      stats_tab.click

    end

    it "checking ssh connection" do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click

      select_node(@node_uid).click
      sleep 3

      hadoop_node_container(@node_name).click
      ssh_port = get_port('ssh')
      puts ssh_port
      token = api_auth(@user_name, @user_pwd)
      puts token

      check_ssh_on_aws_node(@user_name, token, ssh_port)

    end


    it "checking kibana web ui connection " do

      visit('http://hub.devgex.net:8080/signin')
      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click

      select_node(@node_uid).click
      sleep 3

      hadoop_node_container(@node_name).click
      kibana_port = get_port('kibana')

      connect_button('kibana').click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 15
      page.driver.browser.navigate.refresh
      sleep 5
      actual_url = URI.parse(current_url).to_s
      puts "actual result"
      puts actual_url

      if actual_url =~ /http:\/\/p#{kibana_port}.webproxy.devgex.net\/app\/kibana#\//
        if find('.page-header h1').text.should == 'Configure an index pattern'
          puts "Kibana web ui connection works"
        elsif first('center h1').text.should == "401 Authorization Required"
          puts "Kibana: 401 Authorization Required"
          status = 1
        elsif first('center h1').text.should == ""
          puts "Kibana: 502 Bad Gateway"
          status = 4
        else
          puts "Kibana page with incorrect data"
          status = 2
        end
      elsif first('center h1').text.should == "401 Authorization Required"
        puts "Kibana: 401 Authorization Required"
        status = 1

      elsif first('center h1').text.should == ""
        puts "Kibana: 502 Bad Gateway"
        status = 4
      else
        puts "Kibana: Actual URL: #{actual_url} is not match  to  expected URL."
        status = 3

      end

      fail 'Kibana: 401 Authorization Required' if status == 1
      fail 'Kibana page with incorrect data' if status == 2
      fail "Kibana: Actual URL: #{actual_url} is not match  to  expected URL" if status == 3
      fail 'Kibana: 502 Bad Gateway' if status == 4

    end


    it "checking elastic web ui connection" do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click

      select_node(@node_uid).click
      sleep 3


      hadoop_node_container(@node_name).click
      elastic_port = get_port('elastic')


      expected_url = "http://p#{elastic_port}.webproxy.devgex.net/"
      puts "expected url"
      puts expected_url


      connect_button('elastic').click

      window = page.driver.browser.window_handles

      page.driver.browser.switch_to.window(window.last)
      sleep 5
      page.driver.browser.navigate.refresh
      sleep 5
      actual_url = URI.parse(current_url).to_s
      puts actual_url
      check_service_page(actual_url, expected_url, elastic_page(@node_name, @cluster_name), 'elastic')

    end


    it "checking nifi web ui connection " do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click

      select_node(@node_uid).click
      sleep 3

      hadoop_node_container(@node_name).click
      nifi_ip = get_ip('nifi')
      nifi_port = get_port('nifi')
      expected_url = "http://p#{nifi_port}.webproxy.devgex.net/nifi/"
      puts "expected url"
      puts expected_url

      connect_button('nifi').click


      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 20
      page.driver.browser.navigate.refresh
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url
      check_service_page(actual_url, expected_url, nifi_page, 'nifi')

    end

    it "checking neo4j web ui connection " do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click

      select_node(@node_uid).click
      sleep 3


      hadoop_node_container(@node_name).click
      noe4j_port = get_port('neo4j')
      expected_url = "http://p#{noe4j_port}.webproxy.devgex.net/browser/"
      puts "expected url"
      puts expected_url

      connect_button('neo4j').click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 15

      page.driver.browser.navigate.refresh
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url
      check_service_page(actual_url, expected_url, neo4j_page, 'neo4j')

    end

    it "checking kudu web ui connection" do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click

      select_node(@node_uid).click
      sleep 3


      hadoop_node_container(@node_name).click
      kudu_port = get_port('kudu')
      expected_url = "http://p#{kudu_port}.webproxy.devgex.net/"
      puts "expected url"
      puts expected_url

      connect_button('kudu').click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 10
      page.driver.browser.navigate.refresh
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url
      status = check_service_page(actual_url, expected_url, kudu_page, 'kudu')

      fail 'Kudu: 401 Authorization Required' if status == 1
      fail 'Kudu page with incorrect data' if status == 2
      fail "Kudu: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if status == 3
      fail 'Kudu: 502 Bad Gateway' if status == 4

    end


    it "checking metabase web ui connection" do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click

      select_node(@node_uid).click
      sleep 3


      hadoop_node_container(@node_name).click
      metabase_port = get_port('metabase')
      expected_url = "http://p#{metabase_port}.webproxy.devgex.net/setup"
      puts "expected url"
      puts expected_url

      connect_button('metabase').click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 15
      page.driver.browser.navigate.refresh
      sleep 10
      actual_url = URI.parse(current_url).to_s
      puts actual_url
      check_service_page(actual_url, expected_url, metabase_page, 'metabase')



    end


    it "checking superset web ui connection" do

      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click

      select_node(@node_uid).click
      sleep 3


      hadoop_node_container(@node_name).click
      superset_port = get_port('superset')
      expected_url = "http://p#{superset_port}.webproxy.devgex.net/login/"
      puts "expected url"
      puts expected_url

      connect_button('superset').click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 10
      page.driver.browser.navigate.refresh
      actual_url = URI.parse(current_url).to_s
      puts actual_url
      check_service_page(actual_url, expected_url, superset_page, 'superset')

    end

  end

end