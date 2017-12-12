RSpec.describe "Testing main functionality ", :type => :request do

  # gex_env=main user_name=name cluster_id=id cluster_uid=uid cluster_name=name rspec spec/features/clusters/uninstall_cluster_with_node_spec.rb
  describe "Cluster" do
    before(:all) do
      puts 'UNINSTALL AWS CLUSTER WITH NODE'
      if first('#avatar_drop') != nil
        sign_out
      end
      @user_name = ENV['user_name'] || 'ricco'
      @user_pwd = ENV['user_pwd'] || 'Password1'

      @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_name = ENV['cluster_name'] || @user_data['cluster_name']
      @cluster_uid = ENV['cluster_uid'] || @user_data["#{@cluster_name}_data"]['cluster_uid']
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
      cluster_uninstallation(passed, @user_name, 'AWS', @cluster_name, @cluster_id, @cluster_uid, test_exception)

    end

    # Need to specify environment variable: user_name, cluster_name
    it 'delete cluster'  do
      puts "Cluster"

      visit('http://api.galacticexchange.io/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      delete_cluster_with_node(@cluster_uid)
      yes_button.click

      @user_data.delete("cluster_name")
      @user_data.delete("#{@cluster_name}_data")
      File.open("/work/tests/data/users/#{@user_name}.json", 'w') {|f| f << JSON.pretty_generate(@user_data)}

      sleep 240

      team_clusters_tab.click
      sleep 10

      page.all('[ng-repeat="cluster in clusters track by cluster.id"]').each do |item |
        fail "Cluster was not deleted. Cluster state #{cluster_state(@cluster_uid)}" if item.text =~ /.*#{@cluster_name}.*/
      end

      puts "Cluster was uninstalled successfully!!!"


    end
  end

end