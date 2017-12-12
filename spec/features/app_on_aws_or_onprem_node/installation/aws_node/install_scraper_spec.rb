RSpec.describe "Testing install app", :type => :request do

#  gex_env=main user_name=kennedi-abernathy  rspec spec/features/apps/on_premise_or_aws_node/install_datameer_spec.rb
  describe "apps installation" do

    before :all do
      if first('#avatar_drop') != nil
        sign_out
      end

      @user_name = ENV['user_name'] || 'kennedi-abernathy'
      @user_pwd = ENV['user_pwd'] || 'Password1'
      cluster_name = ENV['cluster_name'] || 'thankful-mensa'

      user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_id = ENV['cluster_id'] || user_data["#{cluster_name}"]['cluster_id']
      @cluster_uid = ENV['cluster_uid'] || user_data["#{cluster_name}"]['cluster_uid']
      puts @cluster_id, @cluster_uid
    end

    after :each do
      sign_out
    end

    it 'scraper installation' do


      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
=begin
      app_hub_tab.click

      scraper_install_link.click
      install_button.click

      application_create = wait_log_event("application_create", 240, {cluster_id: @cluster_id.to_i})
      expect(application_create).not_to be_nil
      puts "*************************************************************************************************"
      puts "Event application create"


      application_run = wait_log_event("application_run", 960, {clusterID: @cluster_uid})
      expect(application_run).not_to be_nil
      puts "*************************************************************************************************"
      puts "Event: application run ---> 'vagrant run container' command completed"

=end
      installed_apps_tab.click
      sleep 3
      find('[data-row="app-scraper"]').click

      app_state.should == 'ON'
      sleep 3

      service_data = services_config_on_node
      checking_telnet_connection_on_premise_node(service_data)
      puts service_data
      expected_url = "http://#{service_data[:"Web UI"][:local_ip]}/#/dashboard"
      puts "expected_url"
      puts expected_url

      find('[id="Web UI_block"]').find('.flex-wrap', :text => 'Connect').click

      window = page.driver.browser.window_handles
      page.driver.browser.switch_to.window(window.last)
      sleep 5
      page.driver.browser.navigate.refresh
      sleep 5

      actual_url = URI.parse(current_url).to_s
      puts "actual  url"
      puts actual_url

      status = check_service_page(actual_url, expected_url, scraper_page, 'scraper')

      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      stats_tab.click

      fail 'Datameer: 401 Authorization Required' if status == 1
      fail 'Datameer page with incorrect data' if status == 2
      fail "Datameer: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if status == 3

    end
  end
end










