# requirements:
# * user should exist
# * cluster should exist
# input:
# * specify user with params username, user_pwd, team_id,
# * cluster - cluster_id, cluster_uid


RSpec.describe "Install node in AWS cluster", :type => :request do


  describe 'install' do

    before :each do
      @username = ENV['username'] || 'celestine'
      @password = ENV['user_pwd'] || 'Password1'
      @team_id = ENV['team_id']
      @cluster_uid = ENV['cluster_uid'] || '1703330982054804'
      @cluster_id = (ENV['cluster_id'] || '387').to_i

      #@aws_config = get_aws_config(ENV['aws_config'])
      @aws_config = get_aws_config('key1')

      @aws_region = 'us-west-2'

      # auth
      @token = api_auth(@username, @password)

      #
=begin
      @cluster_data = {
          clusterType: 'aws',
          awsRegion: @aws_region,
          awsKeyId: @aws_config['key_id'],
          awsSecretKey: @aws_config['secret_key'],

      }
=end

      #
      @fog = AwsHelper.fog(@aws_region, @aws_config)

    end


    it "install" do
      @nNodes=1
      @instance_type = 't2.medium'

      resp = api_do_request :post, 'nodes/add', {clusterID: @cluster_uid, instanceType: @instance_type}, {'token' => @token}
      data = JSON.parse(resp.body)

      expect(resp.code).to eq 200


=begin
      --- offset: 1464516, partition: 0, key: , type: debug_login, date: 2017-01-13T11:36:10.984Z
      --- offset: 1464582, partition: 0, key: , type: node_adding, date: 2017-01-13T11:36:24.173Z
      --- offset: 1464583, partition: 0, key: , type: node_creating, date: 2017-01-13T11:36:24.300Z
      --- offset: 1464584, partition: 0, key: , type: , date: 2017-01-13T11:36:24.622Z
      --- offset: 1464585, partition: 0, key: , type: , date: 2017-01-13T11:36:25.335Z
      --- offset: 1464593, partition: 0, key: , type: node_created, date: 2017-01-13T11:36:25.502Z

      --- offset: 1464598, partition: 0, key: , type: node_master_installing, date: 2017-01-13T11:36:25.631Z
      --- offset: 1464600, partition: 0, key: , type: hadoop_application_created, date: 2017-01-13T11:36:26.496Z
      --- offset: 1464601, partition: 0, key: , type: hadoop_provision_start, date: 2017-01-13T11:36:26.608Z
      --- offset: 1464602, partition: 0, key: , type: ansible_start, date: 2017-01-13T11:36:26.748Z
      --- offset: 1464638, partition: 0, key: , type: debug_login, date: 2017-01-13T11:36:34.751Z
      --- offset: 1464687, partition: 0, key: , type: ansible_ok, date: 2017-01-13T11:36:42.397Z
      --- offset: 1464688, partition: 0, key: , type: hadoop_provision_result, date: 2017-01-13T11:36:42.527Z
      --- offset: 1464689, partition: 0, key: , type: node_master_installed, date: 2017-01-13T11:36:42.662Z


=end

      log_data = {cluster_id: @cluster_id}


      event = wait_log_event("node_creating", 600, log_data)
      expect(event).not_to be_nil

      event = wait_log_event(["node_created", "node_create_error"], 600, log_data)
      expect(event).not_to be_nil
      expect(event['type_name']).to eq 'node_created'


      node_id = event['data']['node_id']
      log_data[:node_id] = node_id


      [
          "node_master_installing",
          'hadoop_application_created',
          'hadoop_provision_start'
      ].each do |event_name|
        event = wait_log_event(event_name, 600, log_data)
        expect(event).not_to be_nil
      end


      event = wait_log_event('hadoop_provision_result', 600, log_data)
      expect(event).not_to be_nil
      expect(event['data']['res']).to eq true



      event = wait_log_event(['node_master_installed', 'node_master_install_error'], 600, log_data)
      expect(event).not_to be_nil
      expect(event['type_name']).to eq 'node_master_installed'



      # aws installing
      event = wait_log_event(['node_aws_installing'], 600, log_data)
      expect(event).not_to be_nil

      event = wait_log_event('node_aws_install_result', 600, log_data)
      expect(event).not_to be_nil
      expect(event['data']['res']).to eq true


      # gexd
      event = wait_log_event('node_status_changed', 600, log_data)
      expect(event).not_to be_nil
      expect(event['data']['to']).to eq 'installing'




=begin
register new ClusterGX instance - api POST /instances with params: awsInstanceID
API register new instance - in db field options[awsInstanceID] = awsInstanceID
run gex node install with params: --nodeID=XXX --agentToken=XXX, which
gexd: calls API PUT /nodes with params: instanceID, sysinfo, agentToken
API: updates node info with sysinfo, instanceID; updates instance.last_node_id=XX
gexd: calls API GET /nodeInfo
gexd continues installing node on the machine
gexd calls API POST /notify with event=node_installed
API set node status=active
=end

    end
  end
end
