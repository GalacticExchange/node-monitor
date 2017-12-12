module ServersHelpers
  @@servers = nil

  def self.init_servers_config
    filename = File.expand_path("data/servers/servers.#{$gex_env}.json", $root_dir)
    @@servers = JSON.parse(File.read(filename))
  end

  def self.get_servers_config
    if @@servers.nil?
      init_servers_config
    end

    @@servers
  end

  def self.load_server_config(hostname)
    puts "get info for server #{hostname}"
    #$server_config = {}

    # all servers list
    all_servers = ServersHelpers.get_servers_config


    res = all_servers[hostname] || {}


    # if exist custom server
    server_name = ENV['server'] || hostname
    server_config = GexcloudHelpers.get_server_config(server_name)

    puts "config for server #{hostname}: #{server_config}"

    if server_config
      res.merge! server_config

      init_server_info_from_env(res)
      return res
    end


    # it is gexcloud server
    gexcloud_servers = GexcloudHelpers.get_servers_config


    if gexcloud_servers[hostname]
      server_config = gexcloud_servers[hostname] || {}
      #server_config.delete('host')
      res.merge! server_config

      return res
    end

    # default
    if res.nil? || res['host'].nil?
      res = {
          'host' =>  ENV['TARGET_HOST'],
          'type' => ENV['TARGET_HOST_TYPE'],
          'user' => ENV['SSH_USER'],
          'password' => ENV['SSH_PASSWORD']
      }
    end

    # set from env
    init_server_info_from_env(res)

    res
  end


  def self.init_server_info_from_env(res)
    res['host'] = ENV['server_host'] if ENV['server_host']
    res['user'] = ENV['server_user'] if ENV['server_user']
    res['password'] = ENV['server_pwd'] if ENV['server_pwd']

    res
  end

end
