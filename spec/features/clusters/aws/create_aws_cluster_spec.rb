RSpec.describe "Testing main functionality ", :type => :request do
  # gex_env=main user_name=name user_id=id aws_region="US East (Ohio - us-east-2)"  rspec spec/features/clusters/create_aws_cluster_spec.rb
  describe "Create new cluster" do
    before(:all) do

      if first('#avatar_drop') != nil
        sign_out
      end

      @user_name = ENV['user_name'] || 'kennedi-abernathy' #'kennedi-abernathy''night-tester'
      @user_pwd = ENV['user_pwd'] || 'Password1'
      @aws_region = ENV['aws_region'] || "US East (Ohio - us-east-2)"

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @user_id = ENV['user_id'] || @user_data['user_id']
      puts @user_id

    end

    after(:each) do |example|
      sign_out

      if example.exception != nil
        passed = false
        test_exception = example.exception.to_s
      else
        passed = true
      end
      slack_msg_create_cluster(passed, @user_name, @user_id, 'AWS', @cluster_name, @cluster_id, @cluster_uid, test_exception)

    end


    it 'create aws cluster' do
      puts 'CREATE AWS CLUSTER'

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      create_cluster_button.click if first('[data-div="aws-card"]') == nil
      aws_card.next_btn.click
      next_step_btn.click
      select_aws_region(@aws_region)
      #fill_config_form_for_aws(@aws_region)
      using_of_saved_key
      create_aws_cluster_btn.click


      cluster_created = wait_log_event("cluster_created", 90, {user_id: @user_id.to_i})
      fail 'Log type cluster_created was not sent to Kafka' if cluster_created == nil
      #expect(cluster_created).not_to be_nil
      puts "*************************************************************************************************"
      puts "Cluster created"

      @cluster_id = cluster_created['cluster_id'].to_i
      @cluster_name = cluster_created['data']['cluster']['name']
      @cluster_uid = cluster_created['data']['cluster']['id']
      puts @cluster_name, @cluster_id, @cluster_uid

      @user_data.merge!("aws": {"cluster_name": "#{@cluster_name}", "#{@cluster_name}_data": {"cluster_id" => @cluster_id, "cluster_uid" => @cluster_uid}})
      File.open("/work/tests/data/users/#{@user_name}.json", 'w') {|f| f << JSON.pretty_generate(@user_data)}

      hadoop_install_start = wait_log_event("hadoop_install_start", 90, {cluster_id: @cluster_id.to_i})
      fail 'Log type hadoop_install_start was not sent to Kafka' if hadoop_install_start == nil
      #expect(hadoop_install_start).not_to be_nil
      puts "*************************************************************************************************"
      puts "Hadoop install start"

      cluster_status_changed = wait_log_event("cluster_status_changed", 600, {cluster_id: @cluster_id.to_i, to: "installed"})
      fail 'Log type cluster_status_changed: from installing to installed was not sent to Kafka' if cluster_status_changed == nil
      #expect(cluster_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Cluster status changed: installing ---> installed"

      cluster_installed = wait_log_event("cluster_installed", 60, {cluster_id: @cluster_id.to_i})
      fail 'Log type cluster_installed was not sent to Kafka' if cluster_installed == nil
      #expect(cluster_installed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Cluster was installed"

      team_clusters_tab.click
      sleep 10
      cluster_state(@cluster_uid).should == "ON"

    end
  end

end