RSpec.describe "Testing node management ", :type => :request do
# gex_env=main user_name=kennedi-abernathy cluster_id=752 cluster_uid=3171938370604632 node_uid=1719409652058891 rspec spec/features/nodes/aws/core_node/aws_node_management_spec.rb
  describe "nodes management" do
    before(:all) do
      if first('#avatar_drop') != nil
        sign_out
      end

      @user_name = ENV['user_name'] || 'kennedi-abernathy'
      @user_pwd = 'Password1'
      @cluster_name =  ENV['cluster_name'] || 'black-cancer'
      @node_name = ENV['node_name'] || 'delightful-agena'

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_id = ENV['cluster_id'] || @user_data["#{@cluster_name}"]['cluster_id']
      @cluster_uid = ENV['cluster_uid'] || @user_data["#{@cluster_name}"]['cluster_uid']
      @node_uid = ENV['node_uid'] || @user_data["#{@cluster_name}"]["#{@node_name}"]['node_uid']

      puts @cluster_id, @cluster_uid, @node_uid

      @tests_passed = []
      @tests_failed = {}

    end

    after(:each) do |example|

      if example.exception != nil
        test_exception = example.exception.to_s
        @tests_failed.merge!(example.description => test_exception)
      else
        @tests_passed << example.description
      end
    end

    after(:all) do
      if @tests_failed.size != nil
        passed = false
        SlackHelper.test_send({
                                  passed: passed,
                                  event: 'AWS NODE MANAGEMENT: STOP, START, RESTART',
                                  data:
                                      <<-EOF

  Cluster: #{@cluster_name}, id = #{@cluster_id}
  Node: #{@node_name}
  Failed tests:
               #{@tests_failed}
  Passed tests:
                 #{@tests_passed}

                                  EOF
                              })

      else
        passed = true
        SlackHelper.test_send({
                                  passed: passed,
                                  event: 'AWS NODE MANAGEMENT: STOP, START, RESTART',
                                  data: <<-EOF

  Cluster: #{@cluster_name}, id = #{@cluster_id}
  Node: #{@node_name}

  Passed tests:
               #{@tests_passed}
                                  EOF
                              })

      end
    end



    it 'stop node'  do

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click
      switch_to_cluster(@cluster_uid)
      nodes_tab.click
      sleep 5

      select_node(@node_uid).node_state.should == 'ON'
      select_node(@node_uid).status_checks.should == '1/1 passed'
      select_node(@node_uid).click
      stop_button.click

      node_status_changed = wait_log_event("node_status_changed", 240, {from:"stopping", to:"stopped", cluster_id: @cluster_id.to_i})
      expect(node_status_changed).not_to be_nil
      puts "changed status: stopping --> stopped"

      nodes_tab.click
      select_node(@node_uid).click
      sleep 5

      node_state.should == 'OFF'
    end


    it 'start node'  do

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click


      switch_to_cluster(@cluster_uid)

      nodes_tab.click
      select_node(@node_uid).click
      sleep 5

      node_state.should == 'OFF'
      start_button.click

      node_status_changed = wait_log_event("node_status_changed", 240, {to:"active", cluster_id: @cluster_id.to_i})
      expect(node_status_changed).not_to be_nil
      puts "Changed status: starting ---> active"

      nodes_tab.click
      sleep 60
      page.driver.browser.navigate.refresh
      select_node(@node_uid).node_state.should == 'ON'
      select_node(@node_uid).status_checks.should == '1/1 passed'

    end


    it 'restart node'  do

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)

      nodes_tab.click
      sleep 3
      select_node(@node_uid).node_state.should == 'ON'
      select_node(@node_uid).click
      sleep 5

      restart_button.click

      node_status_changed = wait_log_event("node_status_changed", 360, {from:"restarting", to:"active", cluster_id: @cluster_id.to_i})
      expect(node_status_changed).not_to be_nil
      puts "Changed status: starting ---> active"

      nodes_tab.click
      sleep 30
      page.driver.browser.navigate.refresh
      select_node(@node_uid).node_state.should == 'ON'
      select_node(@node_uid).status_checks.should == '1/1 passed'


    end

  end
end