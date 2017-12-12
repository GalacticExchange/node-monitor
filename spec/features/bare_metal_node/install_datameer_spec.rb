RSpec.describe "Testing install app", :type => :request do


  describe "apps installation" do

    before(:all) do

      @user_name = ENV['user_name'] || 'eloy-leannon'
      @user_pwd = 'Password1'
      cluster_name =  ENV['cluster_name'] || 'rich-cygnus'

      user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
      @cluster_id = user_data["#{cluster_name}"]['cluster_id']
      @cluster_uid = user_data["#{cluster_name}"]['cluster_uid']
      puts @cluster_id, @cluster_uid

    end

    after :each do
      sign_out
    end

    it 'datameer installation'  do

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      switch_to_cluster(@cluster_uid)
      app_hub_tab.click
      datameer_install_link.click
      install_button.click

      application_create = wait_log_event("application_create", 240, {cluster_id: @cluster_id})
      expect(application_create).not_to be_nil
      puts "Event application create"


      application_run = wait_log_event("application_run", 800, {clusterID: @cluster_uid})
      expect(application_run).not_to be_nil
      puts "Event: application run ---> 'vagrant run container' command completed"

      find('[data-row="app-datameer"]').click

      app_state.should == 'active'
      sleep 3
      services_name, all_public_ip, all_port = [], [], []
      find_all('td[data-div="service-name"]').each do |x|
        service_name = x.text
        services_name << service_name
      end
      find_all('td[data-div="public_ip"]').each  do |y|
        public_ip = y.text
        all_public_ip << public_ip
        stdout,stderr,status = Open3.capture3("sudo ip route replace #{public_ip} dev docker0")
        STDERR.puts stderr
        if status.success?
          puts stdout
        else
          STDERR.puts "OH NO!"
        end
      end
      find_all('td[data-div="port"]').each  do |z|
        port = z.text
        all_port << port
      end

      for i in 0...services_name.size
        for k in 1..8
          puts "#{services_name[i]}: telnet #{all_public_ip[i]} #{all_port[i]}"
          stdout, stdeerr, status = Open3.capture3("telnet #{all_public_ip[i]} #{all_port[i]}")
          if stdout =~ /Connected/
            puts "STDOUT: #{stdout}"
            break
          elsif stdout =~ /Trying/
            puts k
            sleep 60
            puts "STDOUT: #{stdout}" if k == 8
            fail "Failed to connect to service #{services_name[i]}" if k == 8
          else
            puts "STDOUT: #{stdout}"
            fail "Failed to connect to service #{services_name[i]}"
          end
        end
      end
      end

    it 'test telnet'  do

      # log in ClusterGX
      fill_in 'user_login', :with => 'emery'
      fill_in 'user_password', :with => 'Password1'
      login_button.click

      switch_to_cluster

      installed_apps_tab.click
      sleep 3

      find('[data-row="app-datameer"]').click
      app_state.should == 'active'
      sleep 3
      services_name, all_public_ip, all_port = [], [], []
      find_all('td[data-div="service-name"]').each do |x|
        service_name = x.text
        services_name << service_name
      end
      find_all('td[data-div="public_ip"]').each  do |y|
        public_ip = y.text
        all_public_ip << public_ip
      end
      find_all('td[data-div="port"]').each  do |z|
        port = z.text
        all_port << port
      end

      for i in 0...services_name.size
        for k in 1..8
          puts "#{services_name[i]}: telnet #{all_public_ip[i]} #{all_port[i]}"
          stdout, stdeerr, status = Open3.capture3("telnet #{all_public_ip[i]} #{all_port[i]}")
          if stdout =~ /Connected/
            puts "STDOUT: #{stdout}"
            break
          elsif stdout =~ /Trying/
            puts k
            sleep 60
            puts "STDOUT: #{stdout}" if k == 8
            fail "Failed to connect to service #{services_name[i]}" if k == 8
          else
            puts "STDOUT: #{stdout}"
            fail "Failed to connect to service #{services_name[i]}"
          end
        end
      end

    end
  end
end









