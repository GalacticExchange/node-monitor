RSpec.describe 'Container memory check on local core node ', :type => :request do

# gex_env=main home_directory=julia cluster_id=752 rspec spec/features/nodes/on_premise/core_node/check_containers_size_onprem_node_spec.rb

  before(:all) do

    @cluster_name = ENV['cluster_name'] || "shy"
    @cluster_id = ENV['cluster_id'] || 768
    @node_name = ENV['node_name'] || "shy-mizar"
    @path_to_file = "/work/tests/data/containers_memory_data/aws_core_node/containers_memory_data.json"
    stdout, stdeerr, status = Open3.capture3('pwd')
    puts stdout
    puts "!!!!!!!!!!"
    puts File.exist?(@path_to_file)
    if File.exist?(@path_to_file)
      @memory_data = JSON.parse(File.read(@path_to_file))
      puts @memory_data
      @memory_data.merge!("hadoop_container": {}) if @memory_data["hadoop_container"] == nil
      @memory_data.merge!("hue_container": {}) if @memory_data["hue_container"] == nil
      @memory_data.merge!("datameer_container": {}) if @memory_data["datameer_container"] == nil
      @memory_data.merge!("data_enchilada_container": {}) if @memory_data["data_enchilada_container"] == nil
      @memory_data.merge!("zoomdata_container": {}) if @memory_data["zoomdata_container"] == nil
      @memory_data.merge!("rocana_container": {}) if @memory_data["rocana_container"] == nil
      @memory_data.merge!("scraper_container": {}) if @memory_data["scraper_container"] == nil
      @memory_data.merge!("graph_ide_container": {}) if @memory_data["graph_ide_container"] == nil
      @memory_data.merge!("stanford_core_nlp_container": {}) if @memory_data["stanford_core_nlp_container"] == nil
      File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }
      @memory_data = JSON.parse(File.read(@path_to_file))
      puts @memory_data
    else

      @memory_data = {"hadoop_container": {},
                      "hue_container": {},
                      "datameer_container": {},
                      "data_enchilada_container": {},
                      "zoomdata_container": {},
                      "rocana_container": {},
                      "scraper_container": {},
                      "graph_ide_container": {},
                      "stanford_core_nlp_container": {}

      }

      File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }
      @memory_data = JSON.parse(File.read(@path_to_file))
    end

    @cluster_data = get_aws_cluster_data(@cluster_id)
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






  it 'check hadoop container size'  do
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker system df -v | grep hadoop_cdh | awk '{print $6, $7, $8}'")
    fail "Hadoop container is absent. Your local node is application only node" if stdout == ""
    str_out = stdout.delete! 'ago'
    s = str_out.split(' ')
    image_space_usage = " #{s[0]} #{s[1]}"
    container_size = " #{s[2]} #{s[3]}"
    size = get_size_in_megabytes(image_space_usage) + get_size_in_megabytes(container_size)
    puts "#{size} MB"

    time = Time.now.strftime("%Y-%d-%m %H:%M")
    puts time
    @memory_data["hadoop_container"].merge!({"date:#{time}": size})
    File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }


  end

  it 'check hue container size'  do
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker system df -v | grep hue_cdh | awk '{print $6, $7, $8}'")
    fail "Hue container is absent. Your local node is application only node" if stdout == ""
    str_out = stdout.delete! 'ago'
    s = str_out.split(' ')
    image_space_usage = " #{s[0]} #{s[1]}"
    container_space_usage = " #{s[2]} #{s[3]}"
    size = get_size_in_megabytes(image_space_usage) + get_size_in_megabytes(container_space_usage)
    puts "#{size} MB"

    time = Time.now.strftime("%Y-%d-%m %H:%M")
    puts time
    @memory_data["hue_container"].merge!({"date:#{time}": size})
    File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }


  end


  it 'check datameer container size' do
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker system df -v | grep datameer | awk '{print $6, $7, $8}'")
    fail "Datameer container is absent." if stdout == ""
    str_out = stdout.delete! 'ago'
    s = str_out.split(' ')
    image_space_usage = " #{s[0]} #{s[1]}"
    container_space_usage = " #{s[2]} #{s[3]}"
    size = get_size_in_megabytes(image_space_usage) + get_size_in_megabytes(container_space_usage)
    puts "#{size} MB"

    time = Time.now.strftime("%Y-%d-%m %H:%M")
    puts time
    @memory_data["datameer_container"].merge!({"date:#{time}": size})
    File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }


  end


  it 'check dataenchilada container size' do
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker system df -v | grep data_enchilada | awk '{print $6, $7, $8}'")
    fail "Dataenchilada container is absent." if stdout == ""
    str_out = stdout.delete! 'ago'
    s = str_out.split(' ')
    image_space_usage = " #{s[0]} #{s[1]}"
    container_space_usage = " #{s[2]} #{s[3]}"
    size = get_size_in_megabytes(image_space_usage) + get_size_in_megabytes(container_space_usage)
    puts "#{size} MB"

    time = Time.now.strftime("%Y-%d-%m %H:%M")
    puts time
    @memory_data["dataenchilada_container"].merge!({"date:#{time}": size})
    File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }


  end

  it 'check zoomdata container size' do
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker system df -v | grep zoomdata | awk '{print $6, $7, $8}'")
    fail "Zoomdata container is absent." if stdout == ""
    str_out = stdout.delete! 'ago'
    s = str_out.split(' ')
    image_space_usage = " #{s[0]} #{s[1]}"
    container_space_usage = " #{s[2]} #{s[3]}"
    size = get_size_in_megabytes(image_space_usage) + get_size_in_megabytes(container_space_usage)
    puts "#{size} MB"

    time = Time.now.strftime("%Y-%d-%m %H:%M")
    puts time
    @memory_data["zoomdata_container"].merge!({"date:#{time}": size})
    File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }


  end

  it 'check rocana container size' do
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker system df -v | grep rocana | awk '{print $6, $7, $8}'")
    fail "Rocana container is absent." if stdout == ""
    str = stdout.delete! 'ago'
    s = str.split(' ')
    image_space_usage = " #{s[0]} #{s[1]}"
    container_space_usage = " #{s[2]} #{s[3]}"
    size = get_size_in_megabytes(image_space_usage) + get_size_in_megabytes(container_space_usage)
    puts "#{size} MB"

    time = Time.now.strftime("%Y-%d-%m %H:%M")
    puts time
    @memory_data["rocana_container"].merge!({"date:#{time}": size})
    File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }

  end

  it 'check scraper container size' do
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker system df -v | grep scraper | awk '{print $6, $7, $8}'")
    fail "Scraper container is absent." if stdout == ""
    str = stdout.delete! 'ago'
    s = str.split(' ')
    image_space_usage = " #{s[0]} #{s[1]}"
    container_space_usage = " #{s[2]} #{s[3]}"
    size = get_size_in_megabytes(image_space_usage) + get_size_in_megabytes(container_space_usage)
    puts "#{size} MB"

    time = Time.now.strftime("%Y-%d-%m %H:%M")
    puts time
    @memory_data["scraper_container"].merge!({"date:#{time}": size})
    File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }

  end

  it 'check graphIDE container size' do
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker system df -v | grep ? | awk '{print $6, $7, $8}'")
    fail "GraphIDE container is absent." if stdout == ""
    str = stdout.delete! 'ago'
    s = str.split(' ')
    image_space_usage = " #{s[0]} #{s[1]}"
    container_space_usage = " #{s[2]} #{s[3]}"
    size = get_size_in_megabytes(image_space_usage) + get_size_in_megabytes(container_space_usage)
    puts "#{size} MB"

    time = Time.now.strftime("%Y-%d-%m %H:%M")
    puts time
    @memory_data["graph_ide_container"].merge!({"date:#{time}": size})
    File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }

  end


  it 'check StanfordCoreNLP container size' do
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{@cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{@node_public_ip} docker system df -v | grep ? | awk '{print $6, $7, $8}'")
    fail "StanfordCoreNLP container is absent. Your local node is application only node" if stdout == ""
    str = stdout.delete! 'ago'
    s = str.split(' ')
    image_space_usage = " #{s[0]} #{s[1]}"
    container_space_usage = " #{s[2]} #{s[3]}"
    size = get_size_in_megabytes(image_space_usage) + get_size_in_megabytes(container_space_usage)
    puts "#{size} MB"

    time = Time.now.strftime("%Y-%d-%m %H:%M")
    puts time
    @memory_data["graph_ide_container"].merge!({"date:#{time}": size})
    File.open(@path_to_file, 'w') { |f| f << JSON.pretty_generate(@memory_data) }

  end

end
