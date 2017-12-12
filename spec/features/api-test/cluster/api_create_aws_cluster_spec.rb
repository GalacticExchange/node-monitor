

RSpec.describe "cluster creation", :type => :request do
  before(:all) do

    user_id = 513 #ENV['user_id']
    token = get_user_auth_token('julie', 'Password1')

    request_to_create_aws_cluster(token, "ap-northeast-2")

    cluster_created = wait_log_event("cluster_created", 90, {user_id: user_id})
    expect(cluster_created).not_to be_nil
    puts "!!!!!!!!!!Cluster created"

    @cluster_id = cluster_created['cluster_id']
    puts "CLUSTER_ID = #{@cluster_id}"

    cluster_create_ansible_start = wait_log_event("cluster_create_ansible_start", 240, {cluster_id: @cluster_id})
    expect(cluster_create_ansible_start).not_to be_nil
    puts "!!!!!!!!!Cluster create ansible start"

  #  cluster_create_ansible_result = wait_log_event("cluster_create_ansible_result", 180, {cluster_id: @cluster_id})
  # expect(cluster_create_ansible_result).not_to be_nil
  #  puts "!!!!!!!!!!Cluster create ansible result"

    cluster_status_changed = wait_log_event("cluster_status_changed", 90, {cluster_id: @cluster_id, to:"installed"})
    expect(cluster_status_changed).not_to be_nil
    puts "!!!!!!!!!!!Cluster status changed: installing ---> installed"

    cluster_installed = wait_log_event("cluster_installed", 60, {cluster_id: @cluster_id})
    expect(cluster_installed ).not_to be_nil
    puts "!!!!!!!!!!!!Cluster was installed"

    cluster_status_changed = wait_log_event("cluster_status_changed", 90, {cluster_id: @cluster_id, to:"active"})
    expect(cluster_status_changed).not_to be_nil
    puts "!!!!!!!!!!!!Cluster status changed: installed ---> active"


    @hue_master = "hue-master-#{@cluster_id}"
    @hadoop_master = "hadoop-master-#{@cluster_id}"

    cluster_data = get_aws_cluster_data(@cluster_id)
    @cluster_data  = JSON.parse(cluster_data)
    puts @cluster_data

    aws_region = @cluster_data["region"]
    puts aws_region
    fail "AWS REGION is absent in cluster data" if aws_region == ''
    aws_access_key = @cluster_data["aws_access_key_id"]
    puts aws_access_key
    fail "AWS ACCESS KEY is absent in cluster data" if aws_access_key == ''
    aws_secret_acces_key = @cluster_data["aws_secret_access_key"]
    puts aws_secret_acces_key
    fail "AWS SECRET ACCESS KEY is absent in cluster data" if aws_secret_acces_key == ''
    @key_name = @cluster_data["key_name"]
    puts @key_name
    fail  "KEY NAME is absent in cluster data" if @key_name == ''
    @coordinator_aws_id = @cluster_data["coordinator_aws_id"]
    puts @coordinator_aws_id
    fail "COORDINATOR AWS ID is absent in cluster data" if @coordinator_aws_id == ''

  # noinspection RubyArgCount
    @fog = Fog::Compute.new(
        :provider => 'AWS',
        :region => aws_region,
        :aws_access_key_id => aws_access_key,
        :aws_secret_access_key => aws_secret_acces_key
    )

  end


  it 'has key pair' do
    resp = @fog.describe_key_pairs('key-name' => @key_name).body
    expect(resp['keySet']).not_to eq([])
  end

  it 'has running coordinator' do
    resp =  @fog.describe_instances('instance-id' => @coordinator_aws_id).body
    puts resp
    expect(resp['reservationSet'][0]['instancesSet'][0]['instanceState']['name'] == 'running')


  end

  it "hue-master check" do

    check_master(@hue_master)
  end

  it "hadoop-master check" do
    check_master(@hadoop_master)
  end

  it "hdfs-namenode check in hadoop-master" do
    check_running_service(@hadoop_master, "hadoop-hdfs-namenode" )
  end

  it "hadoop-httpfs check in master" do
    check_running_service(@hadoop_master, "hadoop-httpfs")
  end

  it "hadoop-mapreduce-historyserver check in master" do
    check_running_service(@hadoop_master, "hadoop-mapreduce-historyserver")
  end

  it "hadoop-yarn-resourcemanager check in master" do
    check_running_service(@hadoop_master, "hadoop-yarn-resourcemanager")
  end

  it "spark history check in hadoop-master" do
    check_running_service(@hadoop_master, "spark-history-server")
  end

  it "ssh check in hadoop-master" do
    check_running_service(@hadoop_master, "ssh")
  end

  it "hive-server2 check in hadoop-master" do
    check_running_service(@hadoop_master, "hive-server2")
  end

describe "Telnet connection" do
  before(:all) do
    @hadoop_public_ip = get_public_ip(@hadoop_master, networking_interface = "eth1")
  end


  it "zookeeper-server in hadoop-master" do
    check_running_service(@hadoop_master, "zookeeper-server")
    zookeeper_port = 2181
    check_network_c2181onnection_in_container(@hadoop_master, @hadoop_public_ip, zookeeper_port, "zookeeper-server")
  end

  it "elasticsearch in hadoop-master" do
    check_running_service(@hadoop_master, "elasticsearch")
    elasticsearch_port = 9200
    check_network_connection_in_container(@hadoop_master, @hadoop_public_ip, elasticsearch_port, "elasticsearch")
  end

  it "kafka connection check" do
    check_hadoop_kafka_server(@hadoop_master)
    kafka_port = 9092
    check_network_connection_in_container(@hadoop_master, @hadoop_public_ip, kafka_port, "kafka")
  end

  it "schemaregistry in hadoop-master" do
    check_hadoop_schemaregistry_server(@hadoop_master)
    schemaregistry_port = 8081
    check_network_connection_in_container(@hadoop_master, @hadoop_public_ip, schemaregistry_port, "schemaregistry")
  end


end

  it "openvpn check in master" do
    check_openvpn_in_master
  end

  it "hue- and hadoop-master host check" do
    check_hadoop_hue_host(@hadoop_master, @hue_master)
  end

  it "proxy check  in master" do
    proxy_public_ip = get_public_ip("proxy", networking_interface="eth2")
    proxy_port = get_proxy_port(@cluster_id)
    check_network_connection_in_container("proxy", proxy_public_ip, proxy_port, "proxy")
  end

  it "hive-metastore check in hadoop-master" do
      sleep 20
      check_running_service(@hadoop_master, "hive-metastore")
      hive_port = 9083
      check_network_connection_in_container(@hadoop_master, @hadoop_public_ip, hive_port, "hive-metastore")
  end

  it "cassandra check in hadoop-master " do
      check_running_service(@hadoop_master, "cassandra")
      cassandra_port = 9042
      check_network_connection_in_container(@hadoop_master, @hadoop_public_ip, cassandra_port, "cassandra")
  end



end
