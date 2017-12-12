module SshHelpers
  require 'net/ssh'

  require 'sshkit'
  require 'sshkit/dsl'
  include SSHKit::DSL
  require 'sshkit/sudo'

  def interaction_handler_pwd(client_config)
    {
        "#{client_config['user']}@#{client_config['host']}'s password:" => "#{client_config['password']}\n",
        /#{client_config['user']}@#{client_config['host']}'s password: */ => "#{client_config['password']}\n",
        "password: " => "#{client_config['password']}\n",
        "password:" => "#{client_config['password']}\n",
        "Password: " => "#{client_config['password']}\n",
    }
  end


  class MyInteractionHandler
    def initialize(_map)
      @map = _map
    end

    def on_data(command, stream_name, data, channel)
      #puts "data=== '#{data}'"

      if @map[data]
        channel.send_data(@map[data])
      else
        case data
          when '(current) UNIX password: '
            channel.send_data("old_pw\n")
          when 'Enter new UNIX password: ', 'Retype new UNIX password: '
            channel.send_data("new_pw\n")
          when 'passwd: password updated successfully'
          else
            raise "Unexpected stderr #{stderr}"
        end

      end

    end
  end



  def run_ssh_cmd(host, ssh_user, ssh_pass, cmd)
    srv = ssh_user+'@'+host
    all_servers = [srv]

    output = ''

    on all_servers do |srv|
      as(user: ssh_user) do
        #execute(cmd)
        output = capture(cmd)
      end

      #execute :tar, '-czf', "backup-#{host.hostname}.tar.gz", 'current'
        # Will run: "/usr/bin/env tar -czf backup-one.example.com.tar.gz current"
      #capture(:s3cmd, 'put', backup_filename, target_filename)
    end

    #
    return {     res: 1,      output: output   }


=begin
    Net::SSH.start(host, ssh_user, :password => ssh_pass) do |ssh|
      #output, stderr_data, exit_code, exit_signal = ssh.exec!("#{cmd}")
      output, stderr_data, exit_code, exit_signal = ssh.execute! :sudo, :cp, '~/1.txt', '/tmp/1.txt'

      output_lines = output.split /\n|\r\n/

      if exit_code.to_i>0 || output_lines.length==0
        status = 'error'
      else
        status = 'ok'
      end

      return {
          exit_code: exit_code,
          status: status,
          output: output,
          stderr_data: stderr_data,
          exit_signal: exit_signal,
      }
    end
=end

  end

  def run_ssh_cmd_sudo(hostname, ssh_user, ssh_pass, cmd, handler=nil)
    host = SSHKit::Host.new("#{ssh_user}@#{hostname}")
    host.password = ssh_pass

    puts "run sudo cmd on #{host} as #{ssh_user}, handler: #{handler.inspect}"


    on host do |host|
      as(user: ssh_user) do
        #sudo cmd
        #execute(:sudo, cmd, interaction_handler: handler)
        #execute('sudo touch /tmp/1.txt', interaction_handler: {
        #execute("#{cmd}", interaction_handler: handler)
      end

      execute("#{cmd}", interaction_handler: handler)
    end

    #
    return {res: 1, output: ""}

  rescue => e
    {
        res: 0,
        error: e.message
    }
  end



  def ssh_cmd_copy_sudo(hostname, ssh_user, ssh_pass, source_file, dest_file, handler=nil)
    puts "upload file #{source_file} to #{dest_file}"

    host = SSHKit::Host.new("#{ssh_user}@#{hostname}")
    host.password = ssh_pass

    # scp
    #cmd = "scp #{source_file} #{srv}:#{dest_file}"
    #puts "cmd=#{cmd}"
    #res = `#{cmd}`

    f_temp = "/tmp/#{SecureRandom.uuid}"

    # sshkit
    on host do |host|
      as(user: ssh_user) do

      end

      # NOT WORK with sudo
      #upload! source_file, dest_file

      # upload to temp file
      upload! source_file, f_temp

      # upload to dest
      execute("sudo cp #{f_temp} #{dest_file}", interaction_handler: handler)

    end

    #
    return     {res: 1, output: ""}
  rescue => e
    {
        res: 0,
        error: e.message
    }
  end

end
