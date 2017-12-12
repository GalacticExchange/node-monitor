RSpec.describe "Test Uninstall app", :type => :request do
# requirements
# * gexd should be installed on the client machine
# * node should be installed on the client machine

  describe 'd uninstall existing app' do

    before :each do

      @client_config = get_client_config(ENV['client'])

      @sys_user = @client_config['user']
      @sys_user_pwd = @client_config['password']

      @gex_username = ENV['username']
      @gex_user_pwd = ENV['user_pwd']
      @appname = ENV['app']
      @app_uid = ENV['app_uid']

      # auth
      res = gex_login(@client_config, @gex_username, @gex_user_pwd)

      #
      @token = api_auth @gex_username, @gex_user_pwd


    end

    it "uninstall existing app" do
      # delete /applications
      #hash_post = {applicationName: @appname, nodeID: @node_uid, settings: app_settings}
      hash_post = {id: @app_uid}

      resp = api_do_request :delete, 'applications', hash_post, {'token' => @token}
      expect(resp.code).to eq 200
      resp_data = JSON.parse(resp.body)

      #application_uid = resp_data['applicationID']

      puts "API res: #{resp_data.inspect}"


      ## as gexd
      require 'open-uri'

      # check containers
      cmd = %Q{cd /home/#{@sys_user}/.gex/node && /bin/bash -c "vagrant ssh -- docker ps -a"}
      #cmd = %Q{cd /home/#{@sys_user}/.gex/node && vagrant ssh -- "docker images | grep #{@appname}" }

      res = run_cmd_on_client(@client_config, cmd)
      puts "#{res.inspect}"

      #expect(res[:output]).to match /#{@appname}/


    end

    it "debug" do
      @sys_user = 'mmx'
      @appname = 'rocana'

      # check
      cmd = %Q{cd /home/#{@sys_user}/.gex/node && vagrant ssh -- "docker images | grep #{@appname}" }

      puts "cmd: #{cmd}"
      res = run_cmd_on_client(@client_config, cmd)
      puts "#{res.inspect}"

      expect(res[:output]).to match /#{@appname}/
    end


  end
end

