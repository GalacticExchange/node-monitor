RSpec.describe "Testing node management ", :type => :request do

  describe "nodes management" do
    before(:all) do

      @user_name = ENV['user_name'] || 'eloy-leannon'
      @user_pwd = 'Password1'
      @cluster_name =  ENV['cluster_name'] || 'lively-microscopium'
      @node_name = ENV['node_name'] || 'gigantic-phecda'

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_id = @user_data["#{@cluster_name}"]['cluster_id']
      @cluster_uid = @user_data["#{@cluster_name}"]['cluster_uid']
      @node_uid = @user_data["#{@cluster_name}"]["#{@node_name}"]['node_uid']

      puts @cluster_id, @cluster_uid, @node_uid

    end

    after :each do
      sign_out
    end

    it 'stop node'  do

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click
      switch_to_cluster(@cluster_uid)
      nodes_tab.click
      select_node(@node_uid)
      sleep 5

      node_state.should == 'joined'
      status_checks.should == 'passed'
      stop_button.click

      node_status_changed = wait_log_event("node_status_changed", 240, {from:"stopping", to:"stopped", cluster_id: @cluster_id})
      expect(node_status_changed).not_to be_nil
      puts "changed status: stopping --> stopped"

      nodes_tab.click
      sleep 5

      node_state.should == 'stopped'
    end


    it 'start node'  do

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click


      switch_to_cluster(@cluster_uid)

      nodes_tab.click
      select_node(@node_uid)
      sleep 5

      node_state.should == 'stopped'
      start_button.click


      node_status_changed = wait_log_event("node_status_changed", 240, {to:"active", cluster_id: @cluster_id})
      expect(node_status_changed).not_to be_nil
      puts "Changed status: starting ---> active"

      nodes_tab.click
      find('[data-div="node-state"]').click
      sleep 5

      node_state.should == 'joined'
      sleep 20
      status_checks.should == 'passed'

    end


    it 'restart node'  do

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)

      nodes_tab.click
      select_node(@node_uid)
      find('[data-div="node-state"]').click
      sleep 5


      restart_button.click

      node_status_changed = wait_log_event("node_status_changed", 360, {to:"active", cluster_id: @cluster_id})
      expect(node_status_changed).not_to be_nil
      puts "Changed status: starting ---> active"


      nodes_tab.click
      find('[data-div="node-state"]').click
      sleep 5

      node_state.should == 'joined'
      status_checks.should == 'passed'



    end
  end
end