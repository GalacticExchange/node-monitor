RSpec.describe "checking hue and hadoop containers inside on-premise cluster", :type => :request do

# gex_env=main user_name=name cluster_id=569 rspec spec/features/clusters/check_hue_hadoop_inside_on_prem_cluster_spec.rb
  # gex_env=main user_name=night-tester rspec spec/features/clusters/check_hue_hadoop_inside_on_prem_cluster_spec.rb

  before(:all) do
    @user_name = ENV['user_name'] || 'kennedi-abernathy' #'night-tester'

    @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
    @cluster_name = ENV['cluster_name'] || @user_data['on_premise']['cluster_name']
    @cluster_id = ENV['cluster_id'] || @user_data['on_premise']["#{@cluster_name}_data"]['cluster_id']
    puts @cluster_name, @cluster_id

    @hue_master = "hue-master-#{@cluster_id}"
    puts @hue_master
    @hadoop_master = "hadoop-master-#{@cluster_id}"
    puts @hadoop_master

    @tests_passed = []
    @tests_failed = {}

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
    slack_msg_check_cluster(passed, @user_name, 'ON-PREMISE', @cluster_name, @cluster_id, @tests_passed, @tests_failed)
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

  describe "Ports check" do
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
end
