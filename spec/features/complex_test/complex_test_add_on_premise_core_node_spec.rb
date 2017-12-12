RSpec.describe "Complex test ", :type => :request do

  # gex_env=main user_name=supertester user_pwd=Password1 user_id=534 rspec spec/features/complex_test/complex_test_add_on_premise_core_node_spec.rb
  describe "adding local node" do

    before :all do
      if first('#avatar_drop') != nil
        sign_out
      end

    end

    after :all do
      sign_out
    end
=begin
    it "create on-premise cluster" do

      @@user_name = ENV['user_name'] || 'kennedi-abernathy'
      user_id = ENV['user_id'] || 525
      @@user_pwd = ENV['user_pwd'] || 'Password1'


      fill_in 'user_login', :with => @@user_name
      fill_in 'user_password', :with => @@user_pwd
      login_button.click

      sleep 3

       if first('button', :text => 'Create cluster') != nil
         create_cluster_button.click
       end

      page.driver.browser.navigate.refresh if on_premise_card == nil

      on_premise_card.next_btn.click
      next_step_btn.click
      create_on_premise_cluster_btn.click


      cluster_created = wait_log_event("cluster_created", 90, {user_id: user_id.to_i})
      expect(cluster_created).not_to be_nil
      puts "*************************************************************************************************"
      puts "Cluster created"

      @@cluster_id = cluster_created['cluster_id']
      @@cluster_uid = cluster_created['data']['cluster']['id']
      puts @@cluster_id, @@cluster_uid

      hadoop_install_start = wait_log_event("hadoop_install_start", 360, {cluster_id: @@cluster_id})
      expect(hadoop_install_start).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Hadoop install start"

      cluster_status_changed = wait_log_event("cluster_status_changed", 800, {cluster_id: @@cluster_id, to:"installed"})
      expect(cluster_status_changed).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Cluster status changed: installing ---> installed"

      cluster_installed = wait_log_event("cluster_installed", 240, {cluster_id: @@cluster_id})
      expect(cluster_installed ).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Cluster was installed"

      team_clusters_tab.click
      sleep 20
      page.driver.browser.navigate.refresh if team_clusters_tab == nil
      cluster_state(@@cluster_uid).should == "ON"
    end


    it "install local core node" do

      page.driver.browser.navigate.refresh
      switch_to_cluster(@@cluster_uid)
      page.driver.browser.navigate.refresh if nodes_tab == nil
      nodes_tab.click
      page.driver.browser.navigate.refresh if add_nodes_btn== nil

      add_nodes_btn.click
      local_node_card.next_btn.click
      core_node_card.next_btn.click
      install_node_button.click
      page.driver.browser.navigate.refresh if nodes_tab== nil

      nodes_tab.click

      node_installed = wait_log_event("node_installed", 600, {cluster_id: @@cluster_id})
      expect(node_installed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Event node installed"

      @@node_name = node_installed['data']['node_name']
      @@node_uid = node_installed['nodeID']

      node_status_changed = wait_log_event("node_status_changed", 600, {from:"installing", to:"installed", cluster_id: @@cluster_id})
      expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Changed status: installing ---> installed"

      node_status_changed = wait_log_event("node_status_changed", 360, {from:"installed", to:"starting", cluster_id: @@cluster_id})
      expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Changed status: installed ---> starting"

      vagrant_up = wait_log_event("vagrant_up", 600, {clusterID: @@cluster_uid})
      expect(vagrant_up).not_to be_nil
      puts "*************************************************************************************************"
      puts "Vagrant up"

      node_status_changed = wait_log_event("node_status_changed", 360, {from:"starting", to:"active", cluster_id: @@cluster_id})
      expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Changed status: starting ---> active"

      nodes_tab.click
      sleep 20

      select_node(@@node_uid).node_state.should == 'ON'
      select_node(@@node_uid).status_checks.should == '1/1 passed'
      select_node(@@node_uid).click

      checking_hadoop_services_connection_on_premise_node(@@node_name)
      click_on_the_back_button
      checking_hue_services_connection_on_premise_node(@@node_name)
    end
=end
    it "stop node" do
      nodes_tab.click
      page.driver.browser.navigate.refresh
      sleep 3

      select_node(@@node_uid).node_state.should == 'ON'
      select_node(@@node_uid).status_checks.should == '1/1 passed'
      select_node(@@node_uid).click
      stop_button.click

      vagrant_halt = wait_log_event("vagrant_halt", 180, {clusterID: @@cluster_uid})
      expect(vagrant_halt).not_to be_nil
      puts "*************************************************************************************************"
      puts "vagrant_halt"

      node_status_changed = wait_log_event("node_status_changed", 240, {from:"stopping", to:"stopped", cluster_id: @@cluster_id})
      expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "changed status: stopping --> stopped"

      nodes_tab.click
      select_node(@@node_uid).click
      sleep 3

      node_state.should == 'OFF'
    end

    it "start node" do

      nodes_tab.click
      select_node(@@node_uid).click
      sleep 3

      node_state.should == 'OFF'
      start_button.click

      vagrant_up = wait_log_event("vagrant_up", 240, {clusterID: @@cluster_uid}) # vagrant_up_error
      expect(vagrant_up).not_to be_nil
      puts "*************************************************************************************************"
      puts "Vagrant up"

      node_status_changed = wait_log_event("node_status_changed", 240, {to:"active", cluster_id: @@cluster_id})
      expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Changed status: starting ---> active"

      nodes_tab.click
      sleep 20

      select_node(@@node_uid).node_state.should == 'ON'
      check_node_status_checks(@@node_uid)
      select_node(@@node_uid).click
      checking_hadoop_services_connection_on_node(@@node_name)

      click_on_the_back_button
      checking_hue_services_connection_on_node(@@node_name)


    end

    it "restart node" do

      @@node_uid = '1717385413400906'
      @@node_name = 'suhail'
      @@cluster_id = 653
      @@cluster_uid = '3171734102096491'
      @@user_name = ENV['user_name'] || 'kennedi-abernathy'
      @@user_pwd = ENV['user_pwd'] || 'Password1'

      nodes_tab.click
      sleep 3
      select_node(@@node_uid).node_state.should == 'ON'
      select_node(@@node_uid).click
      sleep 5

      restart_button.click

      vagrant_reload_up = wait_log_event("vagrant_reload_up", 480, {clusterID: @@cluster_uid})
      expect(vagrant_reload_up).not_to be_nil
      puts "*************************************************************************************************"
      puts "vagrant_reload_up"

      node_status_changed = wait_log_event("node_status_changed", 180, {from: "restarting", to:"active", cluster_id: @@cluster_id})
      expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "changed status: restarting ---> active"

      nodes_tab.click
      sleep 20
      select_node(@@node_uid).node_state.should == 'ON'
      check_node_status_checks(@@node_uid)
      select_node(@@node_uid).click
      checking_hadoop_services_connection_on_node(@@node_name)

      click_on_the_back_button
      checking_hue_services_connection_on_node(@@node_name)
    end

    it "uninstall node" do

      click_on_the_back_button
      page.driver.browser.navigate.refresh
      settings_node_button.click
      uninstall_button.click
      yes_button.click

      node_status_changed = wait_log_event("node_status_changed", 240, {to:"uninstalling", cluster_id: @@cluster_id})
      expect(node_status_changed).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Changed status: active ---> uninstalling"

      remove_box_event = wait_log_event("node_uninstall_remove_box", 480, {clusterID: @@cluster_uid})
      expect(remove_box_event).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Remove box"

      remove_config_files = wait_log_event("node_uninstall_remove_config_files", 360, {clusterID: @@cluster_uid})
      expect(remove_config_files).not_to be_nil
      puts "Remove config_files"

      node_status_changed = wait_log_event("node_status_changed", 240, {to:"uninstalled", cluster_id: @@cluster_id})
      expect(node_status_changed).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Changed status: uninstalling ---> uninstalled"


      node_status_changed = wait_log_event("node_status_changed", 360, {to:"removed", cluster_id: @@cluster_id})
      expect(node_status_changed).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Chaged status removing ---> removed"

      page.driver.browser.navigate.refresh if stats_tab == nil
      stats_tab.click

      sleep 3
      fail ('Node was not deleted') if first('button', :text => 'Add nodes') == nil
      puts "Node was uninstalled successfully"

    end

    it "delete cluster" do

      clusters_button.click
      page.driver.browser.navigate.refresh
      delete_cluster_on_clusters_page(@@cluster_uid)
      yes_button.click

      cluster_status_changed = wait_log_event("cluster_status_changed", 240, {cluster_id: @@cluster_id, to:"uninstalling"})
      expect(cluster_status_changed).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Cluster status changed: ---> to uninstalling"

      hadoop_uninstall_start = wait_log_event("hadoop_uninstall_start", 240, {cluster_id: @@cluster_id})
      expect(hadoop_uninstall_start).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Hadoop uninstall start"

      hadoop_uninstalled = wait_log_event("hadoop_uninstalled", 240, {cluster_id: @@cluster_id})
      expect(hadoop_uninstalled).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Hadoop uninstalled"

      cluster_status_changed = wait_log_event("cluster_status_changed",240, {cluster_id: @@cluster_id, to: "uninstalled"})
      expect(cluster_status_changed).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Cluster status changed:  --->  to uninstalled"

      cluster_status_changed = wait_log_event("cluster_status_changed", 120, {cluster_id: @@cluster_id, to: "removing"})
      expect(cluster_status_changed).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Cluster status changed:  --->  to removing"


    end

  end
end