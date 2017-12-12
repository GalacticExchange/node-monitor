RSpec.describe "Testing uninstall app", :type => :request do

  # gex_env=main user_name=kennedi-abernathy cluster_id=535 cluster_uid=3171573504674961 rspec spec/features/apps/uninstall_dataenchilada_spec.rb
  describe "uninstall app(dataenchilada)" do

    before(:all) do

      if first('#avatar_drop') != nil
        sign_out
      end

      @user_name = ENV['user_name'] || 'kennedi-abernathy'
      @user_pwd = 'Password1'
      cluster_name =  ENV['cluster_name'] || 'sparkling-aries'

      user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_id = ENV['cluster_id'] || user_data["#{cluster_name}"]['cluster_id']
      @cluster_uid = ENV['cluster_uid'] || user_data["#{cluster_name}"]['cluster_uid']
      puts @cluster_id, @cluster_uid

    end

    after :each do
      sign_out
    end


    it 'uninstall dataenchilada'  do

      # log in ClusterGX
      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      app_hub_tab.click

      dataenchilada_open_link.click
      settings_app_button.click

      uninstall_app_button.click

      yes_button.click

      application_uninstall= wait_log_event("application_uninstall", 180, {clusterID: @cluster_uid})
      expect(application_uninstall).not_to be_nil
      puts "'Application uninstall: 'Vagrant uninstall container' command complited."

      installed_apps_tab.click
    end
  end

end