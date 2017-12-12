RSpec.describe "checking hue and hadoop containers inside cluster", :type => :request do

  # gex_env=main user_name=name cluster_name=name cluster_id=id rspec spec/features/clusters/check_hue_hadoop_inside_aws_cluster_spec.rb
  before(:all) do

    puts 'VERIFY CLUSTER UNINSTALLATION'
    @user_name = ENV['user_name'] || 'kennedi-abernathy' #'night-tester'
    @user_data = JSON.parse(File.read("/work/tests/data/users/#{@user_name}.json"))
    @cluster_name= ENV['cluster_name'] || @user_data['aws']['cluster_name']
    @cluster_id = ENV['cluster_id'] || @user_data['aws']["#{@cluster_name}_data"]['cluster_id']
    @cluster_gex_ip = ENV['cluster_gex_ip'] || @user_data['aws']["#{@cluster_name}_data"]['cluster_hadoop_gex_ip']
    puts @cluster_name, @cluster_id,  @cluster_gex_ip


    @hue_master = "hue-master-#{@cluster_id}"
    @hadoop_master = "hadoop-master-#{@cluster_id}"

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

      cluster_info = {}
      cluster_info = @user_data['aws']
      @user_data['aws'].delete("cluster_name")
      @user_data['aws'].delete("#{@cluster_name}_data")
      @user_data.delete('aws') if cluster_info.size == 0
      File.open("/work/tests/data/users/#{@user_name}.json", 'w') { |f| f << JSON.pretty_generate(@user_data) }
=begin
"aws": {
    "cluster_name": "gentle-hydrus",
    "gentle-hydrus_data": {
      "cluster_id": 923,
      "cluster_uid": "3172280259190695",
      "node_name": "faint-rasalhague",
      "faint-rasalhague_data": {
        "aws node": "core_node",
        "node_uid": "1722860972468937"
      },
      "cluster_hadoop_gex_ip": "51.77.3.155"
    }
  }

=end

    end

    verify_cluster_uninstallation(passed, @user_name, 'AWS', @cluster_name, @cluster_id, @tests_passed, @tests_failed)

  end

  it 'hue-master is absent' do
    verify_master_container_absence(@hue_master)
  end

  it 'hadoop-master is absent' do
    verify_master_container_absence(@hadoop_master)
  end

  it 'webproxy: cluster config files are absent' do
    verify_cluster_config_files_absence(@cluster_id)
  end

  it 'openvpn: cluster data is absent' do
    verify_cluster_data_absence_inside_openvpn(@cluster_id)
  end

  it 'systemd: cluster services are absent' do
    verify_cluster_data_absence_on_server(@cluster_id)

  end

  it 'proxy:  cluster processes are absent' do
    verify_cluster_processes_absence(@cluster_gex_ip)
  end

  it 'consul: check cluster service status' do
    verify_failed_cluster_service_status(@cluster_id)

  end



end

