RSpec.describe "Testing main functionality ", :type => :request do
  require 'uri'
  # gex_env=main user_name=name user_id=id aws_region="US East (Ohio - us-east-2)"  rspec spec/features/clusters/create_aws_cluster_spec.rb
  describe "Create new cluster" do
    before(:all) do

      puts 'CREATE AWS CLUSTER'
      if first('#avatar_drop') != nil
        sign_out
      end

      @user_name = ENV['user_name'] || 'ricco'
      @user_pwd = ENV['user_pwd'] || 'Password1'
      @aws_region = ENV['aws_region'] || "US West (N. California - us-west-1)"

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


    it 'create AWS cluster cluster' do

      visit('http://api.galacticexchange.io/signin')

      fill_in 'user_login', :with => @user_name
      fill_in 'user_password', :with => @user_pwd
      login_button.click

      #create_cluster_button.click if first('[data-div="aws-card"]') == nil

      aws_card.next_btn.click
      next_step_btn.click
      select_aws_region(@aws_region)
      #fill_config_form_for_aws(@aws_region)
      using_of_saved_key
      create_aws_cluster_btn.click

      sleep 30
      team_clusters_tab.click

      sleep 5
      @cluster_name = find('[data-div="cluster-name"]').text
      puts @cluster_name


      @user_data.merge!("cluster_name": "#{@cluster_name}")
      File.open("/work/tests/data/users/#{@user_name}.json", 'w') {|f| f << JSON.pretty_generate(@user_data)}
      puts "slepping..."
      sleep 360
      team_clusters_tab.click
      sleep 10


      @cluster_state = find('[data-div="cluster-state"]').text
      for i in 0..8
        puts i
        if @cluster_state != 'ON'
          sleep 20
          puts @cluster_state
        else
          puts "Cluster #{@cluster_name} was created successfully!!!"
          break
        end
      end

      find('[data-div="cluster-name"]').click
      actual_url = URI.parse(current_url).to_s
      puts actual_url
      @cluster_uid = actual_url.split('/')[5]
      puts @cluster_uid

      @user_data.merge!("#{@cluster_name}_data": {"cluster_uid": "#{@cluster_uid}"})
      File.open("/work/tests/data/users/#{@user_name}.json", 'w') {|f| f << JSON.pretty_generate(@user_data)}
      @cluster_id = "-"


    end
  end

end