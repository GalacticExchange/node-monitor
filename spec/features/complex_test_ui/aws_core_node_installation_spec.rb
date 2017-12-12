RSpec.describe "Complex test ", :type => :request do

  # gex_env=main user_name=kennedi-abernathy user_pwd=Password1 user_id=525 rspec spec/features/complex_test/complex_test_add_on_premise_core_node_spec.rb
  describe "adding local node" do

    before :all do
      if first('#avatar_drop') != nil
        sign_out
      end
    end

    after :all do
      sign_out
    end

    it "create aws cluster" do

      user_name = ENV['user_name'] || 'kennedi-abernathy'
      user_pwd = ENV['user_pwd'] || 'Password1'
      aws_region = ENV['aws_region'] || "US East (Ohio - us-east-2)"


      fill_in 'user_login', :with => user_name
      fill_in 'user_password', :with => user_pwd
      login_button.click

      if first('button', :text => 'Create cluster') != nil
        create_cluster_button.click
      end


      title = find('[data-div="page-title"]')
      page.driver.browser.navigate.refresh if title == nil
      title.find('h2').text.should == 'Create cluster'
      title.find('p').text.should == 'Step 1: Choose the type.'

      sleep 3

      aws_card.next_btn.click
      next_step_btn.click
      select_aws_region(aws_region)
      #fill_config_form_for_aws(aws_region)
      using_of_saved_key
      create_aws_cluster_btn.click

      sleep 240
      page.driver.browser.navigate.refresh if team_clusters_tab == nil
      team_clusters_tab.click
      sleep 10
      for i in 0...15
        if find('[data-div="state"]').text != "ON"
          sleep 30
          i = i + 1
          puts i
          fail "Cluster was not installed successfully" if i == 14
        else
        end
      end
      puts "Cluster was created successfully"
    end

    it "install aws core node" do

      find('[data-div="state"]').click
      page.driver.browser.navigate.refresh if nodes_tab == nil
      nodes_tab.click

      add_nodes_btn.click
      core_node_card.next_btn.click
      add_aws_node_btn.click
      yes_button.click
      page.driver.browser.navigate.refresh if nodes_tab == nil
      nodes_tab.click

      sleep 420
      page.driver.browser.navigate.refresh if nodes_tab == nil
      nodes_tab.click
      sleep 3
      for i in 0...12
        if find('[data-div="node-state"]').text != "ON"
          sleep 30
          i = i + 1
          puts i
          nodes_tab.click
          fail "Node was not installed successfully" if i == 11
        else
          for k in 0...12
            if find('[data-div="status-checks"]').text != "1/1 passed"
              sleep 15
              k = k + 1
              puts k
              nodes_tab.click
              fail "Cluster was not installed successfully" if k == 11
            else
            end
          end
        end
      end

      puts "Node was installed successfully"



      node_name = find('[data-div="name"]').text
      puts node_name

      find('[data-div="state"]').click

      checking_hadoop_services_connection_on_node(node_name)
    end

    it "uninstall node" do
      page.driver.browser.navigate.refresh if nodes_tab == nil
      nodes_tab.click


      find('[data-div="node-state"]').click
      page.driver.browser.navigate.refresh if settings_node_button == nil
      settings_node_button.click
      uninstall_button.click
      yes_button.click

      sleep 90
      page.driver.browser.navigate.refresh if stats_tab == nil
      stats_tab.click
      sleep 3
      fail ('Node was not deleted') if first('button', :text => 'Add nodes') == nil
      puts "Node was uninstalled successfully"
    end

    it "delete cluster" do
      user_name = ENV['user_name'] || 'kennedi-abernathy'
      user_pwd = ENV['user_pwd'] || 'Password1'


      fill_in 'user_login', :with => user_name
      fill_in 'user_password', :with => user_pwd
      login_button.click


      clusters_button.click
      page.driver.browser.navigate.refresh
      sleep 3
      find('.col-md-1.hidden-xs.hidden-sm.no_padd_ri.padd_top_md.padd_bott_md').click
      settings_button = find('[data-btn="settings-btn"]')
      settings_button.click
      uninstall_cluster_btn = find('[data-btn="uninstall-cluster"]')
      uninstall_cluster_btn.click
      yes_button.click

      sleep 60

      find('.text-center').find('h2').text == 'Looks like you do not have any clusters yet.'

      puts "Cluster was uninstalled successfully"

    end

  end
end
