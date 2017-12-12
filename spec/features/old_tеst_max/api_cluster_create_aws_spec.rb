# create AWS cluster for existing user
# requirements:
# * user should exist
# input:
# * specify user with params username, user_pwd, team_id

#
require_relative '../../support/helpers/aws_helpers'


RSpec.describe "Create aws cluster via API", :type => :request do
  before :each do
    @username = ENV['username'] || 'kh0'
    @password = ENV['user_pwd'] || 'Password1'

    @team_id = 124

    #@aws_config = get_aws_config(ENV['aws_config'])
    @aws_config = get_aws_config('key1')

    @aws_region = 'us-west-2'

    # auth
    @token = api_auth(@username, @password)



    #
    @cluster_data = {
        clusterType: 'aws',
        awsRegion: @aws_region,
        awsKeyId: @aws_config['key_id'],
        awsSecretKey: @aws_config['secret_key'],

    }

    #
    @fog = AwsHelper.fog(@aws_region, @aws_config)

    #
    @cluster_uid = nil
  end

  describe 'debug' do
    it 'debug' do
      a_instances = @fog.describe_instances.body['reservationSet']

      instance = nil
      a_instances.each do |rr|
        r = rr['instancesSet'][0]

      end

    end
  end

  describe 'create cluster' do
    before :each do
      #
      @cluster_uid = nil
    end


    after :each do
      # delete cluster
      resp = api_do_request :delete, 'clusters', {clusterID: @cluster_uid, token: @token}, {}

    end


    it 'create' do
      #
      resp = api_do_request :post, 'clusters', @cluster_data, {'token' => @token}
      data = JSON.parse(resp.body)

      expect(resp.code).to eq 200

      # cluster created
      event = wait_log_event(["cluster_created", "cluster_create_error"], 60, {team_id: @team_id})
      expect(event).not_to be_nil
      expect(event['type_name']).to eq 'cluster_created'

      cluster_id = event['cluster_id']
      @cluster_uid = cluster_uid = event['data']['cluster']['id']

      puts "cluster created: #{cluster_id}, uid: #{cluster_uid}"

      # check ansible script params

      event = wait_log_event("cluster_create_provision_start", 1200, {team_id: @team_id, cluster_id: cluster_id})
      expect(event).not_to be_nil

      event = wait_log_event("cluster_create_ansible_start", 12600, {team_id: @team_id, cluster_id: cluster_id})
      expect(event).not_to be_nil


      event = wait_log_event("cluster_create_ansible_result", 1200, {team_id: @team_id, cluster_id: cluster_id})
      expect(event).not_to be_nil
      expect(event['data']['res']).to eq true

      event = wait_log_event("cluster_installed", 60, {team_id: @team_id, cluster_id: cluster_id})
      expect(event).not_to be_nil

      event = wait_log_event("cluster_status_changed", 60, {team_id: @team_id, cluster_id: cluster_id, to: 'active'})
      expect(event).not_to be_nil


      ### check aws

      # vpc is created
      vpc = AwsHelper.find_vpc_by_cluster_uid(@fog, cluster_uid)
      expect(vpc).not_to be_nil


      # instance is created
      instance = AwsHelper.find_instance_by_cluster_uid(@fog, cluster_uid)
      expect(instance).not_to be_nil

    end
  end

  describe 'delete cluster' do

    it 'create and delete' do
      # work
      # create
      resp = api_do_request :post, 'clusters', @cluster_data, {'token' => @token}

      resp_data = JSON.parse(resp.body)
      cluster_uid = resp_data['cluster']['id']

      # cluster created
      event = wait_log_event("cluster_created", 60, {team_id: @team_id})
      expect(event).not_to be_nil

      cluster_id = event['cluster_id']


      # wait till installed
      event = wait_log_event("cluster_status_changed", 1200, {team_id: @team_id, cluster_id: cluster_id, to: 'active'})
      expect(event).not_to be_nil


      # delete
      resp = api_do_request :delete, 'clusters', {clusterID: cluster_uid, token: @token}, {}

      # check steps
      event = wait_log_event("cluster_status_changed", 1200, {cluster_id: cluster_id, to: 'uninstalling'})
      expect(event).not_to be_nil

      event = wait_log_event("hadoop_uninstall_start", 1200, {cluster_id: cluster_id})
      expect(event).not_to be_nil

      event = wait_log_event("hadoop_uninstalled", 1200, {cluster_id: cluster_id})
      expect(event).not_to be_nil

      event = wait_log_event("cluster_status_changed", 1200, {cluster_id: cluster_id, to: 'removed'})
      expect(event).not_to be_nil


      # check aws data
      vpc = AwsHelper.find_vpc_by_cluster_uid(@fog, cluster_uid)
      expect(vpc).to be_nil

      #
      instance = AwsHelper.find_instance_by_cluster_uid(@fog, cluster_uid)
      expect(instance).to be_nil
    end


    it 'delete existing' do
      # input
      cluster_uid = ENV['cluster_uid']

      # do nothing if no cluster
      if cluster_uid

        # delete
        resp = api_do_request :delete, 'clusters', {clusterID: cluster_uid, token: @token}, {}

        expect(resp.code).to eq 200

      end

    end

  end

  describe 'aws data' do
    it 'check aws data' do
      # input
      cluster_uid = ENV['cluster_uid'] || '1701296211763024'

      #
      require 'fog'

      fog = Fog::Compute.new(
          :provider => 'AWS',
          :region => @aws_region,
          :aws_access_key_id => @aws_config['key_id'],
          :aws_secret_access_key => @aws_config['secret_key']
      )

      #
      a_instances = fog.describe_instances.body['reservationSet']

      instance = nil
      a_instances.each do |rr|
        r = rr['instancesSet'][0]

        if r['tagSet']['cluster_uid'] == cluster_uid
          instance = r
          break
        end
      end

      expect(instance).not_to be_nil
    end
  end
end
