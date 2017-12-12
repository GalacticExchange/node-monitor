RSpec.describe "Testing main functionality ", :type => :request do
  # gex_env=main
  describe "nodes main functionality (add node)" do

    before(:all) do
      puts 'ADD 2 AWS CORE NODES'
      if first('#avatar_drop') != nil
        sign_out
      end
      @user_name = ENV['user_name'] || 'ricco'
      @user_pwd = ENV['user_pwd'] || 'Password1'

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_name = ENV['cluster_name'] || @user_data['cluster_name']
      @cluster_uid = ENV['cluster_uid'] || @user_data["#{@cluster_name}_data"]['cluster_uid']
      @node_num = ENV['node_num'] || 2
      @cluster_id = '-'


    end

    after(:each) do |example|
      sign_out
      if example.exception != nil
        passed = false
        test_exception = example.exception.to_s
      else
        passed = true
      end
      slack_msg_add_node(passed, @user_name, 'AWS 2 CORE', @cluster_name, @cluster_id, @cluster_uid, @node_name, @node_uid, test_exception)
    end


    it 'add aws node' do

      visit('http://api.galacticexchange.io/signin')


      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      nodes_tab.click


      add_nodes_btn.click
      core_node_card.next_btn.click
      find('.ui-select-toggle b').click
      find('[role="option"]', :text => 't2.xlarge').click
      find('[ng-model="dataForPage.nodeCount"]').set("#{@node_num}")
      add_aws_node_btn.click
      yes_button.click

      sleep 30
      nodes_tab.click
      sleep 10
      @nodes_name_arr = []
      page.all('[ng-repeat="node in nodes track by node.id"]').each do |item|
        @node_name = item.find('[data-div="name"]').text
        @nodes_name_arr << @node_name

      end
      puts "Nodes are installing..."
      puts @nodes_name_arr

      fail "Nodes number is not match to specified. It should be #{@node_num}" if @nodes_name_arr.size != @node_num

      for i in 0..(@nodes_name_arr.size-1)
        @user_data["#{@cluster_name}_data"].merge!("node_#{i+1}": "#{@nodes_name_arr[i]}")
      end
      File.open("/work/tests/data/users/#{@user_name}.json", 'w') { |f| f << JSON.pretty_generate(@user_data) }

      puts "sleeping ..."
      sleep 300
      page.all('[ng-repeat="node in nodes track by node.id"]').each do |item|
        @node_name = item.find('[data-div="name"]').text
        @node_state = item.node_state
        @node_status_checks = item.status_checks
        puts @node_name, @node_state
      end
      puts "sleeping ..."
      sleep 300
      page.all('[ng-repeat="node in nodes track by node.id"]').each do |item|
        @node_name = item.find('[data-div="name"]').text
        @node_state = item.node_state
        @node_status_checks = item.status_checks
        puts @node_name, @node_state
      end
      puts "sleeping ..."
      sleep 400

      nodes_tab.click
       sleep 20
      @node_data = {}

      page.all('[ng-repeat="node in nodes track by node.id"]').each do |item|
        @node_name = item.find('[data-div="name"]').text
        @node_state = item.node_state
        @node_status_checks = item.status_checks
        @node_data.merge!("#{@node_name}": {"state": "#{@node_state}", "status_checks": "#{@node_status_checks}"})
        puts @node_data
      end

      fail "Nodes number is not match to specified. It should be #{@node_num}" if @node_data.size != @node_num
      @node_data.each do |k, v|
        fail "Node #{k} has state: #{v[:state]}" if v[:state] != 'ON'
        fail "Node #{k} has status_checks: #{v[:state]}" if v[:status_checks] == "1/1passed"
      end


    end

  end
end