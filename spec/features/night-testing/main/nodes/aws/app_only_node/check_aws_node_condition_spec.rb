RSpec.describe "check aws node condition", :type => :request do
# gex_env=main slack_channel=night-testing rspec spec/features/nodes/aws/app_only_node/check_aws_node_condition_spec.rb
  before(:all) do
    puts 'VERIFY NODE CONDITION'
    @user_name = ENV['user_name'] ||  'kennedi-abernathy' #'night-tester''kennedi-abernathy'
    @user_pwd = ENV['user_pwd'] || 'Password1'

    @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
    @cluster_name = ENV['cluster_name'] || @user_data['aws']['cluster_name']
    @cluster_id = ENV['cluster_id'] || @user_data['aws']["#{@cluster_name}_data"]['cluster_id']
    @cluster_uid = ENV['cluster_uid'] || @user_data['aws']["#{@cluster_name}_data"]['cluster_uid']
    @node_name = ENV['node_name'] || @user_data['aws']["#{@cluster_name}_data"]['node_name']
    puts @cluster_name, @cluster_id, @cluster_uid, @node_name


    @tests_passed = []
    @tests_failed = {}

    @cluster_data = get_aws_cluster_data(@cluster_id)
    puts "-----"

    aws_region = @cluster_data["_aws_region"]
    puts "aws_region: #{aws_region}"
    fail "AWS REGION is absent in cluster data" if aws_region == ''
    aws_access_key = @cluster_data["_aws_access_key_id"]
    puts "aws_access_key: #{aws_access_key}"
    fail "AWS ACCESS KEY is absent in cluster data" if aws_access_key == ''
    aws_secret_access_key = @cluster_data["_aws_secret_key"]
    puts "aws_secret_access_key: #{aws_secret_access_key}"
    fail "AWS SECRET ACCESS KEY is absent in cluster data" if aws_secret_access_key == ''
    @cluster_data1 = get_aws_cluster_data_on_our_server(@cluster_id)

    @key_name = @cluster_data1["key_name"]
    puts "key_name: #{@key_name}"
    fail "KEY NAME is absent in cluster data" if @key_name == ''
    @coordinator_aws_id = @cluster_data1["coordinator_aws_id"]
    puts "coordinator_aws_id: #{@coordinator_aws_id}"
    fail "COORDINATOR AWS ID is absent in cluster data" if @coordinator_aws_id == ''

    @key_name = @cluster_data1["key_name"]
    # noinspection RubyArgCount
    @fog = Fog::Compute.new(
        :provider => 'AWS',
        :region => aws_region,
        :aws_access_key_id => aws_access_key,
        :aws_secret_access_key => aws_secret_access_key
    )

    @nodes_data = get_aws_node_data_on_our_server(@cluster_id)
    nodes_data_array = @nodes_data
    puts nodes_data_array
    hash_nodes = {}
    nodes_data_array.each do |item|
      puts item["node_name"]
      if item["node_name"] == @node_name
        hash_nodes.merge!("#{@node_name}": {"gex_node_uid": "#{item["gex_node_uid"]}", "node_agent_token": "#{item["node_agent_token"]}",
                                            "aws_instance_id": "#{item["aws_instance_id"]}", "private_ip": "#{item["private_ip"]}"})
      end
    end
    puts "NODE DATA:"
    puts JSON.pretty_generate(hash_nodes)
    @node_aws_instance_id = hash_nodes[:"#{@node_name}"][:aws_instance_id]
    puts "*************"
    puts "node_aws_instance_id: #{@node_aws_instance_id}"

    @instance = @fog.servers.get(@node_aws_instance_id)
    # p @instance.inspect
    #puts @instance.methods.sort
    @node_public_ip = @instance.public_ip_address
    puts "node_public_ip: #{@node_public_ip}"

    aws_key = get_aws_key_on_our_server(@cluster_id)

    File.open("/tmp/ClusterGX_#{@cluster_id}.pem", 'w') { |f| f << aws_key }
    stdout, stdeerr, status = Open3.capture3("sudo chmod 600 /tmp/ClusterGX_#{@cluster_id}.pem")

  end

  after(:each) do |example|
    if example.exception != nil
      test_exception = example.exception.to_s
      @tests_failed.merge!(example.description => test_exception)
    else
      @tests_passed << example.description
    end
  end

  after(:all) do
    if @tests_failed.size != 0
      passed = false
    else
      passed = true
    end

    check_node_condition(passed, @user_name, "AWS APP-ONLY", @cluster_name, @cluster_id, @node_name, @node_public_ip, @tests_passed, @tests_failed)
  end

  it 'check internet connection' do
    stdout, stdeerr, status = Open3.capture3("sudo ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} ping -c 1 8.8.8.8")
    puts stdout
    if stdout =~ /.*\s.*\s\s.*\s.*1 packets transmitted, 1 received, 0% packet loss.*\s.*\s.*/
      puts "Internet  connection available"
    else
      fail 'Internet connection is absent'
    end
  end

  it 'ping openvpn from node VM' do
    openvpn_ip = get_openvpn_ip_aws_node(@cluster_id, @node_public_ip)
    puts "openvpn_ip = #{openvpn_ip}"
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} ping -c 1 #{openvpn_ip}")
    puts stdout
    if stdout =~ /.*\s.*\s\s.*\s.*1 packets transmitted, 1 received, 0% packet loss.*\s.*\s.*/
      puts "Openvpn pings from node VM"
    else
      fail 'Could not ping openvpn from node VM'
    end
  end

  it 'node tunnel end point check' do

    tunel_end_point = get_aws_node_tunnel_end_point(@cluster_id, @node_public_ip)
    puts "tunel_end_point: #{tunel_end_point}"
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} ping -c 1 #{tunel_end_point}")
    puts stdout
    if stdout =~ /.*\s.*\s\s.*\s.*1 packets transmitted, 1 received, 0% packet loss.*\s.*\s.*/
      puts "NODE tunnel end point ping"
    else
      fail 'Could not ping NODE tunnel end point from node VM'
    end


  end


end
