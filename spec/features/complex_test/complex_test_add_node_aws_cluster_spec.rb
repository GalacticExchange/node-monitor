RSpec.describe "Complex test ", :type => :request do
# gex_env=main user_name=kennedi-abernathy user_id=525 rspec spec/features/complex_test/complex_test_add_node_aws_cluster_spec.rb
  describe "adding aws node" do

    before :all do
      if first('#avatar_drop') != nil
        sign_out
      end
        @tests_passed = []
        @tests_failed = {}
    end

    after(:each) do |example|
      sign_out
      page.driver.browser.navigate.refresh

      if example.exception != nil
        test_exception = example.exception.to_s
        @tests_failed.merge!(example.description => test_exception)
        puts @tests_failed

      else
        @tests_passed << example.description
        puts @tests_passed
      end
    end

    after(:all) do
      if @tests_failed.size != 0
        passed = false
        SlackHelper.test_send({
                                  passed: passed,
                                  event: 'COMPLEX TEST: CREATE CLUSTER -> CREATE NODE -> UNINSTALL NODE -> UNINSTALL CLUSTER',
                                  data:
                                      <<-EOF

      Info:
          User: #{@@user_name}
          Cluster:  #{@@cluster_name}, id: #{@@cluster_id}, uid: #{@@cluster_uid} aws_region: #{@@aws_region}
          Node: #{@@node_name}, uid: #{@@node_uid}
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
                                  event: 'COMPLEX TEST: CREATE CLUSTER -> CREATE NODE -> UNINSTALL NODE -> UNINSTALL CLUSTER',
                                  data: <<-EOF

      Info:
          User: #{@@user_name}
          Cluster:  #{@@cluster_name}, id: #{@@cluster_id}, uid: #{@@cluster_uid}, aws_region: #{@@aws_region}
          Node: #{@@node_name}, uid: #{@@node_uid}

      Passed tests:
               #{@tests_passed}
                                  EOF
                              })

      end
    end


    it "create aws cluster" do

      @@user_name = ENV['user_name'] || 'kennedi-abernathy'
      user_id = ENV['user_id'] || 525
      @@user_pwd = ENV['user_pwd'] || 'Password1'
      @@aws_region = ENV['aws_region'] || 'US East (Ohio - us-east-2)'

      fill_in 'user_login', :with => @@user_name
      fill_in 'user_password', :with => @@user_pwd
      login_button.click
      sleep 3
      if first('button', :text => 'Create cluster') != nil
        create_cluster_button.click
      end

      aws_card.next_btn.click
      next_step_btn.click
      select_aws_region(@@aws_region)
      #fill_config_form_for_aws(aws_region)
      using_of_saved_key
      create_aws_cluster_btn.click


      cluster_created = wait_log_event("cluster_created", 90, {user_id: user_id.to_i})
      expect(cluster_created).not_to be_nil
      puts "Cluster created"

      @@cluster_id = cluster_created['cluster_id'].to_i
      @@cluster_name = cluster_created['data']['cluster']['name']
      @@cluster_uid = cluster_created['data']['cluster']['id']
      puts @@cluster_name, @@cluster_id, @@cluster_uid


      hadoop_install_start = wait_log_event("hadoop_install_start", 90, {cluster_id: @@cluster_id})
      #expect(hadoop_install_start).not_to be_nil
      fail 'Log hadoop_install_start was not sent to Kafka' if hadoop_install_start == nil
      puts "Hadoop install start"


      cluster_status_changed = wait_log_event("cluster_status_changed", 600, {cluster_id: @@cluster_id, to: "installed"})
      #expect(cluster_status_changed).not_to be_nil
      fail 'Log cluster_status_changed (installing -> installed) was not sent to Kafka' if cluster_status_changed == nil
      puts "Cluster status changed: installing ---> installed"

      cluster_installed = wait_log_event("cluster_installed", 60, {cluster_id: @@cluster_id})
      #expect(cluster_installed).not_to be_nil
      fail 'Log cluster_installed was not sent to Kafka' if cluster_installed == nil
      puts "Cluster was installed"


      team_clusters_tab.click
      sleep 10
      cluster_state(@@cluster_uid).should == "ON"


    end


    it "adding aws node" do

      fill_in 'user_login', :with => @@user_name
      fill_in 'user_password', :with => @@user_pwd
      login_button.click
      sleep 3

      switch_to_cluster(@@cluster_uid)
      driver.navigate.refresh if nodes_tab == nil

      nodes_tab.click

      add_nodes_btn.click
      core_node_card.next_btn.click
      add_aws_node_btn.click
      yes_button.click
      nodes_tab.click


      node_created = wait_log_event("node_created", 180, {cluster_id: @@cluster_id})
      #expect(node_created).not_to be_nil
      fail 'Log node_created was not sent to Kafka' if node_created == nil
      puts "*************************************************************************************************"
      puts "Event node created"

      @@node_uid = node_created['nodeID']
      @@node_name = find("[data-div=\"#{@@node_uid}\"]").find('[data-div="name"]').text
      puts "**************************************************************************************************"
      puts "NODE_NAME: #{@@node_name}"
      puts "NODE_UID: #{@@node_uid}"

      node_status_changed = wait_log_event("node_status_changed", 600, {to: "installed", cluster_id: @@cluster_id})
      fail 'Log node_status_changed (installing -> installed) was not sent to Kafka' if node_status_changed == nil
      #expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Changed status to installed"

      node_status_changed = wait_log_event("node_status_changed", 600, {to: "starting", cluster_id: @@cluster_id})
      fail 'Log node_status_changed (installed -> starting) was not sent to Kafka' if node_status_changed == nil
      #expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Changed status: installed ---> starting"


      node_status_changed = wait_log_event("node_status_changed", 600, {to: "active", cluster_id: @@cluster_id})
      fail 'Log node_status_changed (starting -> active) was not sent to Kafka' if node_status_changed == nil
      #expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Changed status: starting ---> active"

      nodes_tab.click
      sleep 20

      select_node(@@node_uid).node_state.should == 'ON'
      select_node(@@node_uid).status_checks.should == '1/1 passed'




    end

=begin
    it 'stop node'  do

      nodes_tab.click
      sleep 5

      select_node(@@node_uid).node_state.should == 'ON'
      select_node(@@node_uid).status_checks.should == '1/1 passed'
      select_node(@@node_uid).click
      stop_button.click

      node_status_changed = wait_log_event("node_status_changed", 240, {from:"stopping", to:"stopped", cluster_id: @@cluster_id.to_i})
      expect(node_status_changed).not_to be_nil
      puts "changed status: stopping --> stopped"

      nodes_tab.click
      select_node(@@node_uid).click
      sleep 5

      node_state.should == 'OFF'
    end


    it 'start node'  do
      nodes_tab.click
      select_node(@@node_uid).click
      sleep 5

      node_state.should == 'OFF'
      start_button.click

      node_status_changed = wait_log_event("node_status_changed", 240, {to:"active", cluster_id: @@cluster_id.to_i})
      expect(node_status_changed).not_to be_nil
      puts "Changed status: starting ---> active"

      nodes_tab.click
      sleep 60
      page.driver.browser.navigate.refresh
      select_node(@@node_uid).node_state.should == 'ON'
      select_node(@@node_uid).status_checks.should == '1/1 passed'

    end


    it 'restart node'  do

      nodes_tab.click
      sleep 3
      select_node(@@node_uid).node_state.should == 'ON'
      select_node(@@node_uid).click
      sleep 5

      restart_button.click

      node_status_changed = wait_log_event("node_status_changed", 360, {from:"restarting", to:"active", cluster_id: @@cluster_id.to_i})
      expect(node_status_changed).not_to be_nil
      puts "Changed status: starting ---> active"

      nodes_tab.click
      sleep 30
      page.driver.browser.navigate.refresh
      select_node(@@node_uid).node_state.should == 'ON'
      select_node(@@node_uid).status_checks.should == '1/1 passed'


    end
=end

    it "uninstall aws node" do
      fill_in 'user_login', :with => @@user_name
      fill_in 'user_password', :with => @@user_pwd
      login_button.click
      sleep 3

      switch_to_cluster(@@cluster_uid)

      nodes_tab.click


      select_node(@@node_uid).click
      settings_node_button.click
      uninstall_button.click
      yes_button.click

      node_status_changed = wait_log_event("node_status_changed", 240, {to: "uninstalling", cluster_id: @@cluster_id})
      fail 'Log node_status_changed (active -> uninstalling) was not sent to Kafka' if node_status_changed == nil
      #expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Changed status: active ---> uninstalling"

      node_status_changed = wait_log_event("node_status_changed", 240, {to: "uninstalled", cluster_id: @@cluster_id})
      fail 'Log node_status_changed (uninstalling -> uninstalled) was not sent to Kafka' if node_status_changed == nil
      #expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Changed status: uninstalling ---> uninstalled"

      node_status_changed = wait_log_event("node_status_changed", 360, {to: "removed", cluster_id: @@cluster_id})
      fail 'Log node_status_changed (installed -> removed) was not sent to Kafka' if node_status_changed == nil
      #expect(node_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Chaged status removing ---> removed"

      stats_tab.click
      sleep 10
      fail ('Node was not deleted') if first('button', :text => 'Add AWS nodes') == nil
      puts "Node was uninstalled successfully"

    end


    it "delete cluster" do


      fill_in 'user_login', :with => @@user_name
      fill_in 'user_password', :with => @@user_pwd
      login_button.click
      sleep 5
      delete_cluster_on_clusters_page(@@cluster_uid)
      yes_button.click

      cluster_status_changed = wait_log_event("cluster_status_changed", 240, {cluster_id: @@cluster_id, to: "uninstalling"})
      fail 'Log cluster_status_changed (active -> uninstalling) was not sent to Kafka' if cluster_status_changed == nil
      #expect(cluster_status_changed).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Cluster status changed: ---> to uninstalling"

      hadoop_uninstall_start = wait_log_event("hadoop_uninstall_start", 240, {cluster_id: @@cluster_id})
      fail 'Log hadoop_uninstall_start was not sent to Kafka' if hadoop_uninstall_start == nil
      #expect(hadoop_uninstall_start).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Hadoop uninstall start"

      hadoop_uninstalled = wait_log_event("hadoop_uninstalled", 240, {cluster_id: @@cluster_id})
      fail 'Log hadoop_uninstalled was not sent to Kafka' if hadoop_uninstalled == nil
      #expect(hadoop_uninstalled).not_to be_nil
      puts " "
      puts "*************************************************************************************************"
      puts "Hadoop uninstalled"

      cluster_status_changed = wait_log_event("cluster_status_changed", 480, {cluster_id: @@cluster_id, from: "uninstalling",  to: "uninstalled"})
      fail 'Log cluster_status_changed (uninstalling -> uninstalled) was not sent to Kafka' if cluster_status_changed == nil
      #expect(cluster_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Cluster status changed:  --->  to uninstalled"

      cluster_status_changed = wait_log_event("cluster_status_changed", 240, {cluster_id: @@cluster_id, to: "removing"})
      fail 'Log cluster_status_changed (unnstalled -> removing) was not sent to Kafka' if cluster_status_changed == nil
      #expect(cluster_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Cluster status changed:  --->  to removing"
      sleep 15

      team_clusters_tab.click
      sleep 10
      page.all('[ng-repeat="cluster in clusters track by cluster.id"]').each do |item |
        fail "Cluster was not deleted. Cluster state #{cluster_state(@@cluster_uid)}" if item.text =~ /.*#{@@cluster_name}.*/
      end


    end


  end
end