RSpec.describe "Testing main functionality ", :type => :request do

  # gex_env=main user_name=kennedi-abernathy cluster_id=553 cluster_uid=3171584898590154 cluster_name=important-coma-berenices rspec spec/features/clusters/uninstall_empty_cluster_spec.rb
  describe "Cluster" do
    before(:all) do
      if first('#avatar_drop') != nil
        sign_out
      end
      @user_name = ENV['user_name'] || 'night-tester' # 'kennedi-abernathy'
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
      cluster_uninstallation(passed, @user_name, 'empty AWS', @cluster_name, @cluster_id, @cluster_uid, test_exception)

    end

    # Need to specify environment variable: user_name, cluster_name
    it 'delete cluster'  do
      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      delete_cluster(@cluster_uid)
      yes_button.click

      @user_data.delete("cluster_name")
      @user_data.delete("#{@cluster_name}_data")
      File.open("/work/tests/data/users/#{@user_name}.json", 'w') {|f| f << JSON.pretty_generate(@user_data)}


      cluster_status_changed = wait_log_event("cluster_status_changed", 90, {cluster_id: @cluster_id.to_i, to:"uninstalling"})
      fail 'Log cluster_status_change from active to  uninstalling was not sent to Kafka' if cluster_status_changed == nil
      #expect(cluster_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Cluster status changed: ---> to uninstalling"

      hadoop_uninstall_start = wait_log_event("hadoop_uninstall_start", 240, {cluster_id: @cluster_id.to_i})
      fail 'Log hadoop_uninstall_start was not sent to Kafka' if hadoop_uninstall_start == nil
      #expect(hadoop_uninstall_start).not_to be_nil
      puts "*************************************************************************************************"
      puts "Hadoop uninstall start"

      hadoop_uninstalled = wait_log_event("hadoop_uninstalled", 240, {cluster_id: @cluster_id.to_i})
      fail 'Log hadoop_uninstall was not sent to Kafka' if hadoop_uninstalled == nil
      #expect(hadoop_uninstalled).not_to be_nil
      puts "*************************************************************************************************"
      puts "Hadoop uninstalled"

      cluster_status_changed = wait_log_event("cluster_status_changed", 240, {cluster_id: @cluster_id.to_i, to: "removing"})
      fail 'Log cluster_status_change from uninstalled to  removing was not sent to Kafka' if cluster_status_changed == nil
      #expect(cluster_status_changed).not_to be_nil
      puts "*************************************************************************************************"
      puts "Cluster status changed:  --->  to removing"
      sleep 15

      team_clusters_tab.click
      sleep 10
      page.all('[ng-repeat="cluster in clusters track by cluster.id"]').each do |item |
        fail "Cluster was not deleted. Cluster state #{cluster_state(@cluster_uid)}" if item.text =~ /.*#{@cluster_name}.*/
      end



    end
  end

end