module GexdHelpers

  def data_filename(f)
    filename = File.expand_path("data/#{f}", $root_dir)
    filename
  end

  def get_client_config(client_name)
    #puts "root=#{$root_dir}"
    filename = File.expand_path("data/clients/#{client_name}.json", $root_dir)
    data = JSON.parse(File.read(filename))
    data
  end

  def get_app_config(name)
    filename = File.expand_path("data/apps/#{name}.json", $root_dir)
    res = {}
    if File.exists? filename
      data = JSON.parse(File.read(filename))
      res = data
    else
      filename = File.expand_path("data/apps/#{name}.json.txt", $root_dir)

      # TODO: parse as ruby
      if File.exists? filename
        content = File.read(filename)
        data = {}
        data = eval("data=#{content}")
        res = data
      end

    end

    res
  end

  def get_aws_config(name)
    filename = File.expand_path("data/aws/#{name}.json", $root_dir)
    data = JSON.parse(File.read(filename))
    data
  end

  def save_file(from_filename, to_filename)
    File.open(to_filename, "wb") do |f|
      f.write File.read(from_filename)
      f.close
    end
  end


  def run_cmd_on_client(client_config, cmd)
    return run_ssh_cmd(client_config['host'], client_config['user'], client_config['password'], cmd)
  rescue => e
    {
        res: 0,
        error: e.message
    }

  end

  def run_cmd_on_client_sudo(client_config, cmd)

    return run_ssh_cmd_sudo(
        client_config['host'],
        client_config['user'], client_config['password'],
        "sudo #{cmd}",
        interaction_handler_pwd(client_config)
    )
  end


  def run_cmd_on_client_user_sudo(client_config, cmd)
    user = client_config['user']
    cmd_user = "su - #{client_config['user']} -c '#{cmd}'"
    cmd_user = "sudo -H -u #{client_config['user']} bash -c '#{cmd}' "

    return run_ssh_cmd_sudo(
        client_config['host'], client_config['user'], client_config['password'],
        cmd_user,
        interaction_handler_pwd(client_config)
    )
  rescue => e
    {
        res: 0,
        error: e.message
    }

  end

  def gexd_remove_all(client_config)
    puts "remove all gexd"
    run_cmd_on_client_sudo(client_config, "apt-get purge -y gex")
    run_cmd_on_client_sudo(client_config, "apt-get purge -y gextest")
  end

  def update_gex(client_config)
    #run_cmd_on_client_sudo(client_config, "apt-get purge -y #{Myconfig.config[:gex_package]}")

    puts "update"
    run_cmd_on_client_sudo(client_config, "apt-get -y update")

    puts "install "
    res = run_cmd_on_client_user_sudo(client_config, "sudo apt-get install -y --force-yes #{Myconfig.config[:gex_package]}")

    # update config
    puts "upload config"
    f = File.expand_path("data/gex/config.#{$env}.properties", $root_dir)
    f_out = "/etc/gex/config.properties"
    res = ssh_cmd_copy_sudo(client_config['host'], client_config['user'], client_config['password'], f, f_out, interaction_handler_pwd(client_config))

    puts "res: #{res.inspect}"


  end


  def gex_login(client_config, username, password)
    run_cmd_on_client(client_config, "gex login #{username} -p #{password}")
  end
end
