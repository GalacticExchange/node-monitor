module UITestHelper


  def fill_config_form_for_aws(aws_region)
    key_id = config_form.find('[ng-model="aws_cluster.awsKeyId"]')
    key_id.set(KEY_ID)
    access_key = config_form.find('[ng-model="aws_cluster.awsKeySecret"]')
    access_key.set(ACCESS_KEY)
  end

  def select_aws_region(aws_region)
    config_form = find('.simple-form')
    region = config_form.find('[ng-model="aws_cluster.awsRegion"]').click
    find('[role="option"]', :text => aws_region).click
  end

  def services_config_aws_node
    services_data = {}
    services_name, ports = [], []
    find_all('td[data-div="name"]').each do |x|
      services_name << x.text
    end
    find_all('td[data-div="port"]').each do |z|
      ports << z.text
    end
    for i in 0..services_name.size
      services_data.merge!("#{services_name[i]}": ports[i])
    end

    fail 'Service  selector was not find' if services_name.size == 0
    fail 'Port  selector was not find' if ports.size == 0
    return services_data

  end


  def services_config_on_node

    services_name, local_ips, ports = [], [], []
    find_all('td[data-div="name"]').each do |x|
      services_name << x.text
      #puts services_name
    end
    find_all('td[data-div="port"]').each do |z|
      ports << z.text
      #puts ports
    end
    find_all('td[data-div="local_ip"]').each do |z|
      local_ips << z.text
      #puts local_ips
    end
    fail 'Service  selector was not find' if services_name.size == 0
    fail 'Public IP selector was not find' if local_ips.size == 0
    fail 'Port  selector was not find' if ports.size == 0

    services_data = {}
    for i in 0...services_name.size
      services_data.merge!("#{services_name[i]}": {"local_ip": local_ips[i], "port": ports[i]})

    end
    #return services_name, local_ips, ports
    #puts services_data
    return services_data
  end

  def checking_telnet_connection_on_premise_node(services_data)
    failed_connection = []
    for i in 0...services_data.size
      next if services_data.keys[i] == :HDFS
      next if services_data.keys[i] == :SSH
      for k in 1..8
        puts "#{services_data.keys[i]}: telnet #{services_data[services_data.keys[i]][:local_ip]} #{services_data[services_data.keys[i]][:port]}"
        stdout, stdeerr, status = Open3.capture3("telnet #{services_data[services_data.keys[i]][:local_ip]} #{services_data[services_data.keys[i]][:port]}")
        if stdout =~ /Connected/
          puts "STDOUT: #{stdout}"
          break
        elsif stdout =~ /Trying/
          sleep 60
          puts k*60
          failed_connection << services_data.keys[i] if k == 8
        else
          puts "STDOUT: #{stdout}"
        end
      end

    end

    return failed_connection
  end

  def check_app_open_port_aws_node(cluster_id, node_public_ip, app_name, port)
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{node_public_ip} docker exec #{app_name} nc -w2 -zv 127.0.0.1 #{port} 2>&1")
    i =1
    puts stdout
    if stdout =~ /localhost.*127.0.0.1.*open/
    else
      puts "waiting #{i*60}"
      sleep 60
      i += 1
      fail "#{stdout}" if i == 10
    end

  end

  def check_services_open_port_on_aws_node(cluster_id, node_public_ip, service_ip, port)
    for i in 1..10
      stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{node_public_ip} docker exec hadoop nc -w2 -zv #{service_ip} #{port} 2>&1")
      puts stdout
      if stdout =~ /.*Connection refused.*/
        sleep 30
        i += 1
        puts i
        fail "SDTOUT: #{stdout}" if i == 11
      elsif stdout =~ /Connection to #{service_ip} #{port} port.*succeeded!/
        break
      else
        fail "SDTOUT: #{stdout}"
      end
    end

  end

  def check_services_open_port_onpremise_node(service_ip, port)
    puts port
    for i in 0..10
      stdout, stdeerr, status = Open3.capture3("vagrant ssh -- -t docker exec hadoop nc -w2 -zv #{service_ip} #{port} 2>&1")
      puts stdout
      if stdout =~ /.*Connection refused.*/
        i = i + 1
        puts i
        sleep 30
        fail "SDTOUT: #{stdout}" if i == 10
      elsif stdout =~ /.*Connection to #{service_ip} #{port} port.*succeeded!.*/
        puts '++++++++++++++++++++++++++++='
        puts stdout
        break
      else
        fail "SDTOUT: #{stdout}"
      end

    end
  end

  def checking_hadoop_services_connection_on_node(node_name)

    hadoop_node_container(node_name).click
    sleep 3
    services_data = services_config_on_node
    checking_telnet_connection_on_premise_node(services_data)

  end

  def checking_hue_services_connection_on_node(node_name)

    hue_node_container(node_name).click
    sleep 3
    services_data = services_config_on_node
    checking_telnet_connection_on_premise_node(services_data)

  end

  def connect_button(service_name)
    find("##{service_name}_block").find('.flex-wrap', :text => 'Connect')
  end

  def hadoop_node_container(node_name)
    find('td', :text => "hadoop-#{node_name}")
  end

  def hue_node_container(node_name)
    find('td', :text => "hue-#{node_name}")
  end

  def check_hue_page_main_element

    if find('#jHueTourModal') != nil
      find('#jHueTourModalClose').click
      first('.sidebar-nav') != nil
      puts "Hue web ui connection works"
    elsif find('#jHueTourModal') == nil
      page.driver.browser.close if find('.sidebar-nav') == nil
      puts "Hue web ui connection works"
    else
      puts 'Hue web ui connection does not work'
      page.driver.browser.close
      page.driver.browser.close
    end


  end

  def get_ip(service_name)
    find("##{service_name}_block").find(('td[data-div="local_ip"]')).text
  end

  def get_port(service_name)
    find("##{service_name}_block").find(('td[data-div="port"]')).text
  end


  def check_node_status_checks(node_uid)
    i = 0
    if select_node(@@node_uid).status_checks != '1/1 passed'
      sleep 10
      page.driver.browser.navigate.refresh
      i = i + 1
      fail 'Status checks failed' if i == 6
    end
  end

  def get_vpn_ip_from_container_local_node(container_name)
    stdout, stdeerr, status = Open3.capture3("vagrant ssh -- -t docker exec #{container_name} ifconfig tun0 | grep P-t-P | awk '{split($3, arr, \":\"); print arr[2]}'")
    return stdout
  end

  def get_local_node_end_point_from_container(container_name)
    stdout, stdeerr, status = Open3.capture3("vagrant ssh -- -t docker exec #{container_name} ifconfig tun0 |grep 'inet addr'| awk '{split($2, array, \":\"); print array[2]}'")
    return stdout
  end

  def get_aws_node_end_point_from_container(container_name, cluster_id, node_public_ip)
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{cluster_id}.pem\" vagrant@#{node_public_ip} docker exec #{container_name} ifconfig tun0 |grep 'inet addr'| awk '{split($2, array, \":\"); print array[2]}'")
    return stdout
  end

  def get_vpn_ip_from_container_aws_node(container_name, cluster_id, node_public_ip)
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{node_public_ip} docker exec #{container_name} ifconfig tun0 | grep P-t-P | awk '{split($3, arr, \":\"); print arr[2]}'")
    return stdout
  end

  def get_openvpn_ip_local_node
    stdout, stdeerr, status = Open3.capture3("vagrant ssh -- -t ifconfig tun0 | grep P-t-P | awk '{split($3, array, \":\"); print array[2]}'")
    return stdout
  end

  def get_service_ip_onpremise_node
    stdout, stdeerr, status = Open3.capture3("vagrant ssh -- -t docker exec hadoop ifconfig eth1 | grep 'inet addr' | awk '{split($2, array, \":\"); print array[2]}'")
    return stdout
  end

  def get_local_node_tunnel_end_point
    stdout, stdeerr, status = Open3.capture3("vagrant ssh -- -t ifconfig tun0 |grep 'inet addr'| awk '{split($2, array, \":\"); print array[2]}'")
    return stdout
  end

  def get_openvpn_ip_aws_node(cluster_id, node_publick_ip)
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{node_publick_ip} ifconfig tun0 | grep P-t-P | awk '{split($3, array, \":\"); print array[2]}'")
    return stdout
  end

  def get_aws_node_tunnel_end_point(cluster_id, node_public_ip)
    stdout, stdeerr, status = Open3.capture3("ssh -i \"/tmp/ClusterGX_#{cluster_id}.pem\" -o StrictHostKeyChecking=no vagrant@#{node_public_ip}  ifconfig tun0 |grep 'inet addr'| awk '{split($2, array, \":\"); print array[2]}'")
    return stdout
  end

  def check_service_page(actual_url, expected_url, element1, services_name)
    status = 0
    if actual_url == expected_url
      if element1
        puts "#{services_name.upcase} web ui connection works"
      elsif first('center h1') != nil && first('center h1').text == "401 Authorization Required"
        puts "#{services_name.upcase}: 401 Authorization Required"
        status = 1
      elsif first('center h1') != nil && first('center h1').text == "502 Bad Gateway"
        puts "#{services_name.upcase}: 502 Bad Gateway"
        status = 4
      else
        puts "#{services_name.upcase} web ui connection does not work properly"
        status = 2
      end
    elsif first('center h1') != nil && first('center h1').text == "401 Authorization Required"
      puts "#{services_name.upcase}: 401 Authorization Required"
      status = 1
    elsif first('center h1') != nil && first('center h1').text == "502 Bad Gateway"
      puts "#{services_name.upcase}: 502 Bad Gateway"
      status = 4
    else
      puts "#{services_name.upcase}: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} "
      status = 3
    end

    fail "#{services_name.upcase}: 401 Authorization Required" if status == 1
    fail "#{services_name.upcase}: page with incorrect data" if status == 2
    fail "#{services_name.upcase}:: Actual URL: #{actual_url} is not match  to  expected URL: #{expected_url} " if status == 3
    fail "#{services_name.upcase}:: 502 Bad Gateway" if status == 4



  end

  def hue_page
    first('#jHueTourModal') != nil || first('.sidebar-nav') != nil
  end

  def hue_page_element
    first('.sidebar-nav') != nil
  end

  def kudu_page
    first('pre').text =~ /kudu.*\srevision.*\sbuild type.*\sbuilt by .*/
  end

  def neo4j_page
    first('h3', :text => 'Connect to Neo4j') != nil
  end

  def nifi_page
    first('#graph-controls') != nil
  end

  def elastic_page(node_name, cluster_name)
    puts node_name
    puts cluster_name
    x = find('body pre').text
    p x
    puts x.class
    puts
    find('body pre').text =~ /.*name.*#{node_name}.*.*cluster_name.*#{cluster_name}.*/


  end

  def kibana_page
    find('.page-header h1').text.should == 'Configure an index pattern'
  end

  def metabase_page
    first('[name="form"]') != nil || first('button', :text => "Let's get started")
  end

  def superset_page
    first('#loginbox') != nil
  end

  def aws_node_hue_page
    first('.login-content') != nil
  end

  def datameer_page
    first('#licenseWrapper') != nil
  end

  def scraper_page
    first('.page-header') != nil && find('.page-header').text.should == 'Dashboard'
  end

  def data_enchilada_page
    first('[name="session[name]"]') != nil && first('[name="session[password]"') != nil
  end

  def get_size_in_megabytes(str)
    x = []
    if str =~ /.*GB.*/
      x = str.split(" ")
      size = (x[0].to_f * 1024).round(4)
    elsif str =~ /.*kB.*/
      x = str.split(" ")
      size = (x[0].to_f / 1024).round(4)
    elsif str =~ /.*MB.*/
      x = str.split(" ")
      size = x[0].to_f
    else
      fail "Could not convert this measurement unit #{str}"
    end
    return size
  end

end