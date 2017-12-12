RSpec.describe "Night testing ", :type => :request do

  describe 'main testing: create cluster -> add node ->  delete cluster' do

    before :all do

      @user_name = ENV['user_name'] || 'tina'
      @user_pwd = ENV['user_pwd'] || 'Password1'
      @aws_region = ENV['aws_region'] || "US East (Ohio - us-east-2)"

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @user_id = ENV['user_id'] || @user_data['user_id']
      puts @user_id

      Dir.chdir("/work/tests")

    end


    it 'create/verify/delete cluster and add/verify node' do


      puts 'CLUSTER INSTALLATION'
      stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/create_aws_cluster_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")

      sleep 60

      puts 'CHECK THAT CLUSTER WAS INSTALLED SUCCESSFULLY'

      if first('#avatar_drop') != nil
        sign_out
      end
      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      if first('button', :text => 'Create cluster') == nil && page.all('[ng-repeat="cluster in clusters track by cluster.id"]').size == 0
        puts "CLUSTER WAS NOT INSTALLED"
        stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} aws_region = #{@aws_region} slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/create_aws_cluster_spec.rb >>  ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
        stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name}  slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/check_hue_hadoop_inside_aws_cluster_spec.rb  >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
      elsif page.all('[ng-repeat="cluster in clusters track by cluster.id"]').size >= 1 && first('button', :text => 'Create cluster') != nil
        state = page.all('[ng-repeat="cluster in clusters track by cluster.id"]')[0].find('[data-div="state"]').text
        if state == 'install_error'
          puts "CLUSTER HAS STATE INSTALL_ERROR"
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} aws_region = #{@aws_region} slack_channel=#main_night_testing rspec spec/features/clusters/aws/uninstall_empty_cluster_spec.rb >>  ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} aws_region = #{@aws_region} slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/create_aws_cluster_spec.rb >>  ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/check_hue_hadoop_inside_aws_cluster_spec.rb  >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
        elsif state == 'ON'
          puts "CLUSTER WAS INSTALLED SUCCESSFULLY AND ITS VERIFYING STARTING..."
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name}  slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/check_hue_hadoop_inside_aws_cluster_spec.rb  >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
        elsif state == 'installing'
          sleep 600
          clusters_button.click
          state = page.all('[ng-repeat="cluster in clusters track by cluster.id"]')[0].find('[data-div="state"]').text
          if state == 'install_error'
            puts "CLUSTER HAS STATE INSTALL_ERROR"
          elsif state == 'ON'
            puts "CLUSTER WAS INSTALLED SUCCESSFULLY AND ITS VERIFYING STARTING..."
            stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/check_hue_hadoop_inside_aws_cluster_spec.rb  >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          elsif state == 'installing'
            puts "CLUSTER HAS STATE INSTALLING"
          else
            puts "CLUSTER HAS STATE #{state.upcase}"
          end
        elsif state == 'uninstalling'
          sleep 360
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} aws_region = #{@aws_region} slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/create_aws_cluster_spec.rb >>  ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name}  slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/check_hue_hadoop_inside_aws_cluster_spec.rb  >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
        end
      end

      puts "waiting 60 sec"
      sleep 60

      puts 'NODE INSTALLATION'

      stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/add_aws_core_node_spec.rb  >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
      puts "waiting 60 sec"
      sleep 60

      puts 'CHECK THAT NODE WAS INSTALLED SUCCESSFULLY'

      if first('#avatar_drop') != nil
        sign_out
      end
      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      page.all('[ng-repeat="cluster in clusters track by cluster.id"]')[0].find('[data-div="cluster-name"]').click
      nodes_tab.click
      sleep 5

      if page.all('[ng-repeat="node in nodes track by node.id"]').size == 0
        puts 'NODE WAS NOT INSTALLED SUCCESSFULLY'
        sleep 20
        stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/add_aws_core_node_spec.rb  >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
      elsif page.all('[ng-repeat="node in nodes track by node.id"]').size >= 1
        state = page.all('[ng-repeat="node in nodes track by node.id"]')[0].find('[data-div="state"]').text
        puts state
        if state == 'install_error'
          puts "NODE HAS STATE INSTALL_ERROR"
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} aws_region = #{@aws_region} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/uninstall_aws_node_spec.rb >>  ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/add_aws_core_node_spec.rb  >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/check_aws_node_condition_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          stdout, stdeerr, status = Open3.capture3("gex_env=main browser=chrome user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/checking_sevices_on_aws_core_node_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
        elsif state == 'start_error'
          puts "NODE HAS STATE START_ERROR"
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} aws_region = #{@aws_region} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/uninstall_aws_node_spec.rb >>  ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/add_aws_core_node_spec.rb  >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/check_aws_node_condition_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          stdout, stdeerr, status = Open3.capture3("gex_env=main browser=chrome user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/checking_sevices_on_aws_core_node_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
        elsif state == 'ON'
          puts 'NODE WAS INSTALLED SUCCESSFULLY'
          puts 'VERIFY NODE CONDITION'
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing  rspec spec/features/night-testing/main/nodes/aws/core_node/check_aws_node_condition_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")

          puts 'CHECK  NODES SERVICES'
          stdout, stdeerr, status = Open3.capture3("gex_env=main browser=chrome user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/nodes/aws/core_node/checking_sevices_on_aws_core_node_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
        else
          puts "NODE HAS STATE #{state.upcase}"
        end
      end


      sleep 10
      puts 'DELETING CLUSTER WITH NODE'
      clusters_button.click

      stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/uninstall_cluster_with_node_spec.rb  >>  ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")

      puts 'CHECK THAT CLUSTER WAS DETELED SUCCESSFULLY'


      if first('#avatar_drop') != nil
        sign_out
      end
      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      if page.all('[ng-repeat="cluster in clusters track by cluster.id"]').size == 0
        puts "VERIFYING DELETED CLUSTER"
        stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/verify_cluster_uninstallation_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
        puts "CLUSTER WAS DELETED SUCCESSFULLY"
      elsif page.all('[ng-repeat="cluster in clusters track by cluster.id"]').size !=0
        page.all('[ng-repeat="cluster in clusters track by cluster.id"]').each do |item|
          puts "CLUSTER #{item.find('[data-div="cluster-name"]')} HAS STATE #{item.find('[data-div="state"]')}. IT WAS NOT DELETED SUCCESSFULLY"
          puts "RERUN DELETING CLUSTER #{item.find('[data-div="cluster-name"]')}"
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} aws_region = #{@aws_region} slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/uninstall_cluster_with_node_spec.rb  >>  ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
          puts "VERIFYING DELETED CLUSTER"
          stdout, stdeerr, status = Open3.capture3("gex_env=main user_name=#{@user_name} slack_channel=#main_night_testing rspec spec/features/night-testing/main/clusters/aws/verify_cluster_uninstallation_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/main.log")
        end

      end


    end
  end

end