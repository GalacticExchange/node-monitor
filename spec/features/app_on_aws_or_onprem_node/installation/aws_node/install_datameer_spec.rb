RSpec.describe "Testing install app", :type => :request do

#  gex_env=main user_name=kennedi-abernathy  rspec spec/features/apps/on_premise_or_aws_node/install_datameer_spec.rb
  describe "apps installation" do

    before :all do
      if first('#avatar_drop') != nil
        sign_out
      end

      @user_name = ENV['user_name'] || 'kennedi-abernathy'
      @user_pwd = ENV['user_pwd'] || 'Password1'
      cluster_name = ENV['cluster_name'] || 'kind-lepus'
      @node_name = ENV['node-name'] || 'hollow-alderamin'

      user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_id = ENV['cluster_id'] || user_data["#{cluster_name}"]['cluster_id']
      @cluster_uid = ENV['cluster_uid'] || user_data["#{cluster_name}"]['cluster_uid']
      puts @cluster_id, @cluster_uid

      @cluster_data = get_aws_cluster_data(@cluster_id)
      aws_region = @cluster_data["_aws_region"]
      puts "aws_region: #{aws_region}"
      fail "AWS REGION is absent in cluster data" if aws_region == ''
      aws_access_key = @cluster_data["_aws_access_key_id"]
      puts "aws_access_key: #{aws_access_key}"
      fail "AWS ACCESS KEY is absent in cluster data" if aws_access_key == ''
      aws_secret_access_key = @cluster_data["_aws_secret_key"]
      puts "aws_secret_access_key: #{aws_secret_access_key}"
      fail "AWS SECRET ACCESS KEY is absent in cluster data" if aws_secret_access_key == ''

      @cluster_data1 = get_aws_cluster_data_on_our_server(@cluster_id)
      @key_name = @cluster_data1["key_name"]
      puts "key_name: #{@key_name}"
      fail "KEY NAME is absent in cluster data" if @key_name == ''
      @coordinator_aws_id = @cluster_data1["coordinator_aws_id"]
      puts "coordinator_aws_id: #{@coordinator_aws_id}"
      fail "COORDINATOR AWS ID is absent in cluster data" if @coordinator_aws_id == ''
      @key_name = @cluster_data1["key_name"]

      # noinspection RubyArgCount
      @fog = Fog::Compute.new(
          :provider => 'AWS',
          :region => aws_region,
          :aws_access_key_id => aws_access_key,
          :aws_secret_access_key => aws_secret_access_key
      )

      @nodes_data = get_aws_node_data_on_our_server(@cluster_id)
      nodes_data_array = @nodes_data
      hash_nodes = {}
      nodes_data_array.each do |item|
        puts item["node_name"]
        if item["node_name"] == @node_name
          hash_nodes.merge!("#{@node_name}": {"gex_node_uid": "#{item["gex_node_uid"]}", "node_agent_token": "#{item["node_agent_token"]}",
                                              "aws_instance_id": "#{item["aws_instance_id"]}", "private_ip": "#{item["private_ip"]}"})
        end
      end
      puts "NODE DATA:"
      puts JSON.pretty_generate(hash_nodes)
      @node_aws_instance_id = hash_nodes[:"#{@node_name}"][:aws_instance_id]
      puts "node_aws_instance_id: #{@node_aws_instance_id}"

      @instance = @fog.servers.get(@node_aws_instance_id)
      # p @instance.inspect
      #puts @instance.methods.sort
      @node_public_ip = @instance.public_ip_address
      puts "node_public_ip: #{@node_public_ip}"

      aws_key = get_aws_key_on_our_server(@cluster_id)
      File.open("/tmp/ClusterGX_#{@cluster_id}.pem", 'w') { |f| f << aws_key }
      stdout, stdeerr, status = Open3.capture3("sudo chmod 600 /tmp/ClusterGX_#{@cluster_id}.pem")

    end

    after :each do
      sign_out
    end

    it 'datameer installation' do


      visit('http://hub.devgex.net:8080/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)

      app_hub_tab.click

      datameer_install_link.click
      install_button.click

      application_create = wait_log_event("application_create", 240, {cluster_id: @cluster_id.to_i})
      expect(application_create).not_to be_nil
      puts "*************************************************************************************************"
      puts "Event application create"


      application_run = wait_log_event("application_run", 960, {clusterID: @cluster_uid})
      expect(application_run).not_to be_nil
      puts "*************************************************************************************************"
      puts "Event: application run ---> 'vagrant run container' command completed"

      installed_apps_tab.click
      sleep 3
      datameer.click

      app_state.should == 'ON'
      sleep 3

      service_data = services_config_on_node

      puts service_data
      check_app_open_port_aws_node(@cluster_id, @node_public_ip)
      expected_url = "http://p#{service_data[:webui][:port]}.webproxy.devgex.net/licenseNotFound"
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

      status = check_service_page(actual_url, expected_url, datameer_page, 'datameer')

      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
      stats_tab.click

      fail 'Datameer: 401 Authorization Required' if status == 1
      fail 'Datameer page with incorrect data' if status == 2
      fail "Datameer: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if status == 3

    end
  end
end










