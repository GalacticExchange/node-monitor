RSpec.describe "Testing main functionality ", :type => :request do

  describe "nodes main functionality (uninstall node)" do

    # gex_env=main user_name=kennedi-abernathy cluster_name=skinny-pyxis node_name=easy-canopus cluster_id=685 cluster_uid=3171780873481012 node_uid=1717886108029729 rspec spec/features/nodes/node_management/uninstall_local_node_spec.rb

    before(:all) do

      if first('#avatar_drop') != nil
        sign_out
      end
      @user_name = ENV['user_name'] || 'night-tester'
      @user_pwd = ENV['user_pwd'] || 'Password1'

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_name = ENV['cluster_name'] || @user_data['cluster_name']
      @cluster_id = ENV['cluster_id'] || @user_data["#{@cluster_name}_data"]['cluster_id']
      @cluster_uid = ENV['cluster_uid'] || @user_data["#{@cluster_name}_data"]['cluster_uid']
      @node_name = ENV['node_name'] || @user_data["#{@cluster_name}_data"]['node_name']
      @node_uid = ENV['node_name'] || @user_data["#{@cluster_name}_data"]["#{@node_name}_data"]['node_uid']
      puts @cluster_name, @cluster_id, @cluster_uid, @node_name, @node_uid

    end

    after(:each) do |example|
      sign_out
      if example.exception != nil
        passed = false
        test_exception = example.exception.to_s
      else
        passed = true
      end

      slack_msg_uninstall_node(passed, @user_name, 'AWS APP-ONLY', @cluster_name, @cluster_id, @cluster_uid, @node_name, @node_uid, test_exception)
    end


    it 'uninstall node'  do

      fill_in'user_login', :with => @user_name
      fill_in'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click
      select_node(@node_uid).click
      settings_node_button.click
      uninstall_button.click
      yes_button.click

      node_status_changed = wait_log_event("node_status_changed", 240, {to:"uninstalling", cluster_id: @cluster_id.to_i})
      fail 'Log node_status_changed (from active to uninstalling) was not sent to  Kafka' if node_status_changed == nil
      #expect(node_status_changed).not_to be_nil
      puts "Changed status: active ---> uninstalling"


      @user_data["#{@cluster_name}_data"].delete("node_name")
      @user_data["#{@cluster_name}_data"].delete("#{@node_name}_data")
      File.open("/work/tests/data/users/#{@user_name}.json", 'w') {|f| f << JSON.pretty_generate(@user_data)}


      node_status_changed = wait_log_event("node_status_changed", 240, {to:"uninstalled", cluster_id: @cluster_id.to_i})
      fail 'Log node_status_changed (from uninstalling to uninstalled) was not sent to  Kafka' if node_status_changed == nil
      #expect(node_status_changed).not_to be_nil
      puts "Changed status: uninstalling ---> uninstalled"

      node_status_changed = wait_log_event("node_status_changed", 240, {to:"removed", cluster_id: @cluster_id.to_i})
      fail 'Log node_status_changed (from removing to removed) was not sent to  Kafka' if node_status_changed == nil
      #expect(node_status_changed).not_to be_nil
      puts "Chaged status removing ---> removed"

    end
  end
end