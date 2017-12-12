RSpec.describe "Test install node", :type => :request do

  describe 'install node' do

    before :each do
      # requirements
      # * cluster should be installed
      # * gexd should be installed on client machine

      @client_config = get_client_config(ENV['client'])

      @username = ENV['username']
      @password = ENV['user_pwd']

      # prepare
      #@token = auth_user_hash(@admin_hash)

      # create node
      #post '/nodes', @node_info, {token: @token}

      #resp = last_response
      #resp_node = JSON.parse(resp.body)
      #@node_number = resp_node['nodeNumber']


    end


    it "install node on client" do
      # update gex program
      #res = update_gex(@client_config)

      # auth
      res = gex_login(@client_config, @username, @password)

      # check
      res = run_cmd_on_client(@client_config, "gex user info")

      puts "gex info: #{res.inspect}"

      # check
      output = res[:output]
      expect(output).to match /Username:\s*#{@username}/


      # install node
      res = run_cmd_on_client_user_sudo(@client_config, "gex node uninstall -y -f")
      puts "uninstall res: #{res.inspect}"

      res = run_cmd_on_client_user_sudo(@client_config, "gex node install")

      puts "res: #{res.inspect}"

      expect(res[:res]).to eq 1


    end
  end
end
