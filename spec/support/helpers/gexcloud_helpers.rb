module GexcloudHelpers
  @@servers = nil

  def self.init_servers_config
    filename = File.expand_path("data/servers/gexcloud.#{$gex_env}.json", $root_dir)
    @@servers = JSON.parse(File.read(filename))
  end

  def self.get_servers_config
    if @@servers.nil?
      init_servers_config
    end

    @@servers
  end

  def self.get_server_config(hostname)
    # predefined servers
    if hostname == 'node_local'

      #puts "node---local"
      data = get_server_config_node_local


      #puts "node data: #{data}"

      return data
    end

    # default
    filename = File.expand_path("data/servers_custom/#{hostname}.json", $root_dir)
    data = JSON.parse(File.read(filename))

    return data
  rescue Exception => e
    return nil
  end

  def self.get_server_config_node_local
    #
    filename = File.expand_path("data/servers_custom/node_local.json", $root_dir)
    data = JSON.parse(File.read(filename))

    # get node ip
    # run command locally
    #res = `(cd $HOME/.gex/node && (vagrant ssh -- ifconfig eth1 | grep "inet addr" 2>&1)) 2>&1`
    res = `bash -c 'cd $HOME/.gex/node && (bundle exec /usr/bin/vagrant ssh -- ifconfig eth1 | grep "inet addr")'`

    #puts "res=#{res}"

    ip = res[/addr:([\d\.]+) +/, 1]

    #puts "ip=#{ip}**"
    #exit

    #
    data['host'] = ip

    return data
  end

end
