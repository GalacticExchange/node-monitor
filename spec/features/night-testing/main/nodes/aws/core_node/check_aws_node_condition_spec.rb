RSpec.describe "check aws node condition and hadoop_node_container services", :type => :request do

  # gex_env=main cluster_id=759 node_name=sweet-mimosa rspec spec/features/nodes/aws/core_node/check_aws_node_condition_spec.rb

  before(:all) do
    puts 'VERIFY NODE CONDITION'
    @user_name = ENV['user_name'] || 'kennedi-abernathy' #'night-tester'

    @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
    @cluster_name = ENV['cluster_name'] || @user_data['aws']['cluster_name']
    @cluster_id = ENV['cluster_id'] || @user_data['aws']["#{@cluster_name}_data"]['cluster_id']
    @node_name = ENV['node_name'] || @user_data['aws']["#{@cluster_name}_data"]['node_name']
    puts @cluster_name, @cluster_id, @node_name

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

    @user_data['aws']["#{@cluster_name}_data"]["#{@node_name}_data"].merge!("node_public_ip": "#{@node_public_ip}")
    puts @user_data
    File.open("/work/tests/data/users/#{@user_name}.json", 'w') { |f| f << JSON.pretty_generate(@user_data) }


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

    check_node_condition(passed, @user_name, "AWS CORE", @cluster_name, @cluster_id, @node_name, @node_public_ip, @tests_passed, @tests_failed)
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

  it 'check hadoop container is running' do

    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker ps |grep hadoop")
    puts stdout
    if stdout =~ /.*gex\/hadoop_cdh.*hadoop/
      puts "Hadoop container is running"
    else
      fail 'HADOOP container is not  running'
    end

  end

  it 'check hue container is running' do

    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no  vagrant@#{@node_public_ip} docker ps |grep hue")
    puts stdout
    if stdout =~ /.*gex\/hue_cdh.*hue/
      puts "Hue container is running"
    else
      fail 'Hue container is not  running'
    end

  end

  it 'ping vpn from hadoop container' do

    hadoop_vpn_ip = get_vpn_ip_from_container_aws_node('hadoop', @cluster_id, @node_public_ip)
    puts "hadoop_vpn_ip = #{hadoop_vpn_ip}"
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker exec hadoop ping -c 1 #{hadoop_vpn_ip}")
    puts stdout
    if stdout =~ /.*\s.*\s\s.*\s.*1 packets transmitted, 1 received, 0% packet loss.*\s.*\s.*/
    else
      fail 'Could not ping openvpn from hadoop container '
    end

  end

  it 'ping vpn from hue container' do

    hue_vpn_ip = get_vpn_ip_from_container_aws_node('hue', @cluster_id, @node_public_ip)
    puts "hue_vpn_ip = #{hue_vpn_ip}"
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker exec hue ping -c 1 #{hue_vpn_ip}")
    puts stdout

    if stdout =~ /.*\s.*\s.*\s1 packets transmitted, 1 packets received, 0% packet loss\s.*/
    else
      fail 'Could not ping openvpn from hadoop container '
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

  it 'hadoop tunnel end point check' do

    @hadoop_end_point = get_aws_node_end_point_from_container('hadoop', @cluster_id, @node_public_ip)
    puts "hadoop_vpn_ip = #{@hadoop_end_point}"
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker exec hadoop ping -c 1 #{@hadoop_end_point}")
    if stdout =~ /.*\s.*\s\s.*\s.*1 packets transmitted, 1 received, 0% packet loss.*\s.*\s.*/
    else
      fail 'Could not ping openvpn from hadoop container '
    end
  end

  it 'kibana: checking open port' do
    kibana_port = 5601

    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker exec hadoop service --status-all | grep + | grep [k]ibana")
    puts stdout
    fail 'Kibana service is not  running now' if stdout == ''
    check_services_open_port_on_aws_node(@cluster_id, @node_public_ip, 'localhost', kibana_port)

  end

  it 'elasticsearch: checking open port' do
    elastic_port = 9200

    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker exec hadoop service --status-all | grep + | grep [e]lasticsearch")
    puts stdout
    fail 'Elasticsearch service is not  running now' if stdout == ''
    check_services_open_port_on_aws_node(@cluster_id, @node_public_ip, 'localhost', elastic_port)

  end

  it 'nifi: checking open port' do
    nifi_port = 8080

    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker exec hadoop ps -ef | grep \"/[b]in/sh /usr/local/nifi/bin/nifi.sh start\"")
    puts stdout
    fail 'Elasticsearch service is not  running now' if stdout == ''
    @hadoop_end_point = get_aws_node_end_point_from_container('hadoop', @cluster_id, @node_public_ip)
    puts "hadoop_vpn_ip = #{@hadoop_end_point}"
    service_ip = @hadoop_end_point.delete!("\n")
    check_services_open_port_on_aws_node(@cluster_id, @node_public_ip, service_ip, nifi_port)



  end
  it 'neo4j: checking open port' do
    neo4j_port = 7474

    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker exec hadoop service --status-all | grep + | grep [n]eo4j")
    puts stdout
    fail 'Neo4j service is not  running now' if stdout == ''
    check_services_open_port_on_aws_node(@cluster_id, @node_public_ip, 'localhost', neo4j_port)
  end

  it 'kudu: checking open port' do
    kudu_port = 8050

    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker exec hadoop service --status-all | grep + | grep [k]udu")
    puts stdout
    fail 'Kudu service is not  running now' if stdout == ''

    check_services_open_port_on_aws_node(@cluster_id, @node_public_ip, 'localhost', kudu_port)

  end

  it 'metabase: checking open port' do
    metabase_port = 3000

    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker exec hadoop ps -ef | grep \"[j]ava -jar /usr/local/metabase/metabase.jar\"")
    puts stdout
    fail 'Metabase service is not  running now' if stdout == ''

    check_services_open_port_on_aws_node(@cluster_id, @node_public_ip, 'localhost', metabase_port)

  end

  it 'superset: checking open port' do
    superset_port = 8088

    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker exec hadoop ps -ef | grep \"/[u]sr/bin/python /usr/local/bin/superset runserver\"")
    puts stdout
    fail 'Metabase service is not  running now' if stdout == ''
    check_services_open_port_on_aws_node(@cluster_id, @node_public_ip, 'localhost', superset_port)

  end

end
