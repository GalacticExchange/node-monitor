RSpec.describe "Test install app in virtualbox node", :type => :request do
# requirements
# * gexd should be installed on the client machine
# * node should be installed on the client machine

  describe 'install app' do

    before :each do

      @client_config = get_client_config(ENV['client'])

      @sys_user = @client_config['user']
      @sys_user_pwd = @client_config['password']

      @gex_username = ENV['username']
      @gex_user_pwd = ENV['user_pwd']
      @appname = ENV['app']

      filename_app_tar =  'gex-rocana-0.0.4.07_28_2016_1469732819.tar.gz'


      # auth
      res = gex_login(@client_config, @gex_username, @gex_user_pwd)

      # check
      res = run_cmd_on_client(@client_config, "gex user info")
      #puts "gex info: #{res.inspect}"

      #
      @token = api_auth @gex_username, @gex_user_pwd

      #puts "token: #{@token}"

      #
      @node_uid = get_node_id_on_client(@client_config)

      #puts "node uid: #{@node_uid}"

    end

    it "install app on node" do
      # requirements:
      # - node should be installed

      # post /applications
      #app_settings = get_app_config(@appname)
      app_settings = ""

      hash_post = {applicationName: @appname, nodeID: @node_uid, settings: app_settings}

      resp = api_do_request :post, 'applications', hash_post, {'token' => @token}
      expect(resp.code).to eq 200
      resp_data = JSON.parse(resp.body)

      application_uid = resp_data['applicationID']

      puts "create app API res: #{resp_data.inspect}"


      ## as gexd
      require 'open-uri'

      # settings
      url_tar = 'http://files.gex/containers/'+@filename_app_tar

      app_base_dir = "/home/#{@sys_user}/.gex/node/applications/#{@appname}/"
      file_tar = "#{app_base_dir}#{@appname}.tar.gz"


      # download tar file
      run_cmd_on_client(@client_config, "mkdir -p #{app_base_dir}")

      puts "saving tar to #{file_tar}"

      run_cmd_on_client(@client_config, "cd /tmp && rm #{filename_app_tar} ")

      # good
      #run_cmd_on_client(@client_config, "cd /tmp && wget #{url_tar}; mv #{filename_app_tar} #{file_tar} ")

      # debug
      run_cmd_on_client(@client_config, "cd /tmp && wget #{url_tar}; cp #{filename_app_tar} #{file_tar} ")


      # check
      res = run_cmd_on_client(@client_config, "ls #{app_base_dir}")
      expect(res[:output]).to match /#{@appname}/


      # config file
      filename_config = "#{app_base_dir}config.json"

      if ENV['app_config'] && !ENV['app_config'].empty?
        # save from our file
        filename_local = data_filename('apps/'+ENV['app_config']+".json")
        save_file(filename_local, filename_config)
      else
        # download config from API server
        req_hash = {filename: 'config.json', nodeID: @node_uid, applicationID: application_uid}
        api_download_file filename_config, 'files/download', req_hash, {"token" => @token}
      end

      # install container
      cmd = %Q{cd /home/#{@sys_user}/.gex/node && /bin/bash -c "vagrant --image-file=applications/#{@appname}/#{@appname}.tar.gz --app-name=#{@appname} -- provision --provision-with install_container 2>&1"}

      puts "run cmd: #{cmd}"

      res = run_cmd_on_client(@client_config, cmd)

      puts "#{res.inspect}"
      #puts "#{res[:output]}"

      # check
      cmd = %Q{cd /home/#{@sys_user}/.gex/node && vagrant ssh -- "docker images | grep #{@appname}" }

      puts "cmd: #{cmd}"
      res = run_cmd_on_client(@client_config, cmd)
      puts "#{res.inspect}"

      expect(res[:output]).to match /#{@appname}/

      # run container

      # remove existing container
      cmd = %Q{cd /home/#{@sys_user}/.gex/node && vagrant ssh -- "docker rm -f #{@appname}" }
      res = run_cmd_on_client(@client_config, cmd)

      #
      cmd_vagrant = %Q{vagrant --app-name=#{@appname} --json-file=applications/#{@appname}/config.json -- provision --provision-with run_container}
      cmd = %Q{cd /home/#{@sys_user}/.gex/node && /bin/bash -c "#{cmd_vagrant} 2>&1"}

      puts "run cmd: #{cmd}"

      res = run_cmd_on_client(@client_config, cmd)

      puts "#{res.inspect}"
      #puts "#{res[:output]}"



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

    it 'remove app' do

    end
  end
end

