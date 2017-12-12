RSpec.describe "checking hue and hadoop containers inside cluster", :type => :request do

  # gex_env=main user_name=name cluster_name=name cluster_id=id rspec spec/features/clusters/check_hue_hadoop_inside_aws_cluster_spec.rb
  before(:all) do

    @user_name = ENV['user_name'] || 'kennedi-abernathy' #'night-tester'
    @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
    @cluster_name= ENV['cluster_name'] || @user_data['aws']['cluster_name']
    @cluster_id = ENV['cluster_id'] || @user_data['aws']["#{@cluster_name}_data"]['cluster_id']
    puts @cluster_name, @cluster_id


    @hue_master = "hue-master-#{@cluster_id}"
    @hadoop_master = "hadoop-master-#{@cluster_id}"

    @cluster_data = get_aws_cluster_data(@cluster_id)
    puts @cluster_data

    aws_region = @cluster_data["_aws_region"]
    puts aws_region
    fail "AWS REGION is absent in cluster data" if aws_region == ''
    aws_access_key = @cluster_data["_aws_access_key_id"]
    puts aws_access_key
    fail "AWS ACCESS KEY is absent in cluster data" if aws_access_key == ''
    aws_secret_access_key = @cluster_data["_aws_secret_key"]
    puts aws_secret_access_key
    fail "AWS SECRET ACCESS KEY is absent in cluster data" if aws_secret_access_key == ''

    @cluster_data1 = get_aws_cluster_data_on_our_server(@cluster_id)
    #@cluster_data1  = JSON.parse(@cluster_data1)
    puts @cluster_data1

    @key_name = @cluster_data1["key_name"]
    puts @key_name
    fail "KEY NAME is absent in cluster data" if @key_name == ''
    @coordinator_aws_id = @cluster_data1["coordinator_aws_id"]
    puts @coordinator_aws_id
    fail "COORDINATOR AWS ID is absent in cluster data" if @coordinator_aws_id == ''

    # noinspection RubyArgCount
    @fog = Fog::Compute.new(
        :provider => 'AWS',
        :region => aws_region,
        :aws_access_key_id => aws_access_key,
        :aws_secret_access_key => aws_secret_access_key
    )
    @tests_passed = []
    @tests_failed = {}
  end

  after(:each) do |example|
    if example.exception != nil
      test_exception = example.exception.to_s
      @tests_failed.merge!(example.description => test_exception)
      puts @tests_failed

    else
      @tests_passed << example.description
      puts @tests_passed
    end
  end

  after(:all) do
    if @tests_failed.size != 0
      passed = false
    else
      passed = true
    end
    slack_msg_check_cluster(passed, @user_name, 'AWS', @cluster_name, @cluster_id, @tests_passed, @tests_failed)
  end

  it 'has key pair' do
    resp = @fog.describe_key_pairs('key-name' => @key_name).body
    puts resp
    expect(resp['keySet']).not_to eq([])
  end

  it 'has running coordinator' do
    resp = @fog.describe_instances('instance-id' => @coordinator_aws_id).body
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
    check_running_service(@hadoop_master, "hadoop-hdfs-namenode")
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

  it "impala-catalog check in hadoop-master" do
    check_running_service(@hadoop_master, "impala-catalog")
  end

  it "impala-server check in hadoop-master" do
    check_running_service(@hadoop_master, "impala-server")
  end

  it "impala-state-store check in hadoop-master" do
    check_running_service(@hadoop_master, "impala-state-store")
  end

  describe "Telnet connection" do
    before(:all) do
      @hadoop_public_ip = get_public_ip(@hadoop_master, networking_interface = "eth1")
    end


    it "zookeeper-server in hadoop-master" do
      check_running_service(@hadoop_master, "zookeeper-server")
      zookeeper_port = 2181
      check_network_connection_in_container(@hadoop_master, @hadoop_public_ip, zookeeper_port, "zookeeper-server")
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

    it 'hive-metastore check in hadoop-master' do
      check_running_service(@hadoop_master, "hive-metastore")
      hive_port = 9083
      check_network_connection_in_container(@hadoop_master, @hadoop_public_ip, hive_port, "hive-metastore")
    end

    it 'cassandra check in hadoop-master' do
      check_running_service(@hadoop_master, "cassandra")
      cassandra_port = 9042
      check_network_connection_in_container(@hadoop_master, @hadoop_public_ip, cassandra_port, "cassandra")
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

end

