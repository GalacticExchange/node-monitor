RSpec.describe "Testing install app", :type => :request do

  # gex_env=main user_name=kennedi-abernathy cluster_id=535 cluster_uid=3171573504674961 rspec spec/features/apps/install_dataenchilada_spec.rb

  describe "apps installation (dataenchilada)" do

    before(:all) do

      if first('#avatar_drop') != nil
        sign_out
      end
      @user_name = ENV['user_name'] || 'ricco'
      @user_pwd = ENV['user_pwd'] || 'Password1'

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_name = ENV['cluster_name'] || @user_data['cluster_name']
      @cluster_uid = ENV['cluster_uid'] || @user_data["#{@cluster_name}_data"]['cluster_uid']


    end

    after(:each) do |example|
      sign_out
      if example.exception != nil
        passed = false
        test_exception = example.exception.to_s
      else
        passed = true
      end

      slack_msg_add_app(passed, @user_name, 'AWS', 'DATAENCHILADA', @cluster_name, @cluster_id,  @cluster_uid, @node_name, test_exception)
    end


    it 'dataenchilada installation' do

      visit('http://api.galacticexchange.io/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)

      app_hub_tab.click
      dataenchilada_install_link.click
      install_button.click

      installed_apps_tab.click
      sleep 360

      installed_apps_tab.click
      sleep 3
      dataenchilada.click

      app_state.should == 'ON'
      sleep 3


      service_data = services_config_on_node
      failed_connection = checking_telnet_connection_on_premise_node(service_data)
      fail "Failed to connect (telnet check): #{failed_connection}" if failed_connection.size > 0
      puts service_data
      expected_url = "http://#{service_data[:webui][:local_ip]}/sessions/new "
      puts "expected_url"
      puts expected_url

      connect_button.click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 5
      page.driver.browser.navigate.refresh
      sleep 5

      actual_url = URI.parse(current_url).to_s
      puts "actual  url"
      puts actual_url

      status = check_service_page(actual_url, expected_url, data_enchilada_page, 'dataenchilada')

      find('[name="session[name]"]').set("admin")
      find('[name="session[password]"').set("admin")

      find('button', :text => "Sign in").click
      first('.left-menu-h').text.should == 'WORKSPACE'
      puts 'DataEnchilada web ui connection works'

      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      stats_tab.click

      fail 'DataEnchilada: 401 Authorization Required' if status == 1
      fail 'DataEnchilada page with incorrect data' if status == 2
      fail "DataEnchilada: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if status == 3


    end
  end
end

