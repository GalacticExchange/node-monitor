RSpec.describe "cluster creation", :type => :request do
  before(:all) do
=begin
    user_id = 513 #ENV['user_id']
    token = get_user_auth_token('julie', 'Password1')

    request_to_create_onprem_cluster(token)

    cluster_created = wait_log_event("cluster_created", 90, {user_id: user_id})
    expect(cluster_created).not_to be_nil
    puts "!!!!!!!!!!Cluster created"

    @cluster_id = cluster_created['cluster_id']
    puts "CLUSTER_ID = #{@cluster_id}"

    cluster_create_ansible_start = wait_log_event("cluster_create_ansible_start", 200, {cluster_id: @cluster_id})
    expect(cluster_create_ansible_start).not_to be_nil
    puts "!!!!!!!!!Cluster create ansible start"

    cluster_create_ansible_result = wait_log_event("cluster_create_ansible_result", 180, {cluster_id: @cluster_id})
    expect(cluster_create_ansible_result).not_to be_nil
    puts "!!!!!!!!!!Cluster create ansible result"

    cluster_status_changed = wait_log_event("cluster_status_changed", 90, {cluster_id: @cluster_id, to:"installed"})
    expect(cluster_status_changed).not_to be_nil
    puts "!!!!!!!!!!!Cluster status changed: installing ---> installed"

    cluster_installed = wait_log_event("cluster_installed", 60, {cluster_id: @cluster_id})
    expect(cluster_installed ).not_to be_nil
    puts "!!!!!!!!!!!!Cluster was installed"

    cluster_status_changed = wait_log_event("cluster_status_changed", 90, {cluster_id: @cluster_id, to:"active"})
    expect(cluster_status_changed).not_to be_nil
    puts "!!!!!!!!!!!!Cluster status changed: installed ---> active"
=end
    @cluster_id = 380

    @hue_master = "hue-master-#{@cluster_id}"
    puts @hue_master
    @hadoop_master = "hadoop-master-#{@cluster_id}"
    puts @hadoop_master

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
    check_hadoop_schemaregistry_server(@hadoop_master)
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
