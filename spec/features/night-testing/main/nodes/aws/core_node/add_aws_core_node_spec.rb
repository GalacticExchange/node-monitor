RSpec.describe "Testing main functionality ", :type => :request do
  # gex_env=main user_name=kennedi-abernathy cluster_name=kind-lepus cluster_id=723 cluster_uid=3171853473648909 rspec /work/tests/spec/features/nodes/aws/core_node/add_aws_core_node_spec.rb
  describe "nodes main functionality (add node)" do

    before(:all) do
      if first('#avatar_drop') != nil
        sign_out
      end

      @user_name = ENV['user_name']
      @user_pwd = ENV['user_pwd'] || 'Password1'

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_name = ENV['cluster_name'] || @user_data['aws']['cluster_name']
      @cluster_id = ENV['cluster_id'] || @user_data['aws']["#{@cluster_name}_data"]['cluster_id']
      @cluster_uid = ENV['cluster_uid'] || @user_data['aws']["#{@cluster_name}_data"]['cluster_uid']
      puts @cluster_name, @cluster_id, @cluster_uid



    end

    after(:each) do |example|
      sign_out
      if example.exception != nil
        passed = false
        test_exception = example.exception.to_s
      else
        passed = true
      end
      slack_msg_add_node(passed, @user_name, 'AWS CORE', @cluster_name, @cluster_id,  @cluster_uid, @node_name, @node_uid, test_exception)
    end


    it 'add aws node' do

      puts 'ADD AWS CORE NODE'
      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      containers_tab.click
      @gex_ip = get_master_gex_ip(@cluster_uid)


      @user_data['aws']["#{@cluster_name}_data"].merge!("cluster_hadoop_gex_ip" => @gex_ip)
      File.open("/work/tests/data/users/#{@user_name}.json", 'w') {|f| f << JSON.pretty_generate(@user_data)}

      nodes_tab.click

      add_nodes_btn.click
      core_node_card.next_btn.click
      find('.ui-select-toggle b').click
      find('[role="option"]', :text => 't2.xlarge').click
      add_aws_node_btn.click
      yes_button.click
      nodes_tab.click


      node_created = wait_log_event("node_created", 180, {cluster_id: @cluster_id.to_i})
      fail "Node was not created. Log type node_created was not sent to  Kafka" if node_created == nil
      puts "*************************************************************************************************"
      puts "Event node created"

      @node_uid = node_created['nodeID']
      puts "**************************************************************************************************"
      puts "NODE_UID: #{@node_uid}"

      @node_name = find("[data-div=\"#{@node_uid}\"]").find('[data-div="name"]').text
      puts "**************************************************************************************************"
      puts "NODE_NAME: #{@node_name}"

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @user_data['aws']["#{@cluster_name}_data"].merge!("node_name": "#{@node_name}", "#{@node_name}_data": {"aws node": "core_node", "node_uid": "#{@node_uid}"})
      puts @user_data
      File.open("/work/tests/data/users/#{@user_name}.json", 'w') { |f| f << JSON.pretty_generate(@user_data) }

      nodes_tab.click

      node_status_changed = wait_log_event("node_status_changed", 800, {to: "installed", cluster_id: @cluster_id.to_i})
      fail "Log type node_status_changed from installing to installed was not  sent to Kafka. " if node_status_changed == nil
      puts "*************************************************************************************************"
      puts "NODE changed status to installed"


      node_status_changed = wait_log_event("node_status_changed", 600, {to: "starting", cluster_id: @cluster_id.to_i})
      fail "Log type node_status_changed from installed to starting was not  sent to Kafka. " if node_status_changed == nil
      puts "*************************************************************************************************"
      puts "NODE changed status: installed ---> starting"


      node_status_changed = wait_log_event("node_status_changed", 600, {to: "active", cluster_id: @cluster_id.to_i})
      fail "Log type node_status_changed from starting to active was not  sent to Kafka. " if node_status_changed == nil
      puts "*************************************************************************************************"
      puts "NODE changed status: starting ---> active"

      nodes_tab.click
      sleep 20

      select_node(@node_uid).node_state.should == 'ON'
      select_node(@node_uid).status_checks =~ /.*1\/1 passed.*/


    end

  end
end