RSpec.describe "Debug", :type => :request do

  describe 'smth' do

    before :each do
      # requirements
      # * cluster should be installed
      # * gexd should be installed on client machine

      @client_config = get_client_config(ENV['client'])

      @username = ENV['username']
      @password = ENV['user_pwd']

    end


    it 'debug' do

      # debug
      pwd = 'Password1'

      handler_map = {

          /sudo: */ => pwd+'\n',
          /.*password: */ => pwd+'\n',
          'elvis@51.1.0.15\'s password: ' => pwd+'\n',
          'elvis@51.1.0.15\'s password:' => pwd+'\n',
          '[sudo] password for elvis:' => pwd+'\n',
          '[sudo] password for elvis: ' => pwd+'\n',
      }

      handler = SSHKit::MappingInteractionHandler.new(handler_map, :debug)
      #handler = SSHKit::MappingInteractionHandler.new({}, :info)

      class MyInteractionHandler
        def initialize(_map)
          @map = _map
        end

        def on_data(command, stream_name, data, channel)
          puts "data=== '#{data}'"

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

      handler = MyInteractionHandler.new(handler_map)

      #cmd = 'sudo cp /tmp/0.txt /etc/gex/config.properties'
      cmd = 'service elasticsearch restart'
      #run_ssh_cmd_sudo('51.1.0.15', 'elvis', 'Password1', "sudo #{cmd}", handler)

      host = SSHKit::Host.new("elvis@51.1.0.15")
      host.password = "Password1"

      on host do |host|
        #sudo "#{cmd}", interaction_handler: handler
        #execute("sudo #{cmd}", interaction_handler: handler)
        execute("sudo #{cmd}", interaction_handler: handler)

        #as(user: ssh_user) do
        # NOT WORK with sudo
        #upload! source_file, dest_file

        # upload to temp file
        #upload! source_file, f_temp

        # upload to dest
        #execute("#{cmd}", interaction_handler: handler)

        #end
      end

      #f = File.expand_path("data/gex/config.#{$env}.properties", $root_dir)
      #f_out = "/etc/gex/config.properties"
      #res = ssh_cmd_copy_sudo(@client_config['host'], @client_config['user'], @client_config['password'], f, f_out, interaction_handler_pwd(@client_config))

      #
    end
  end
end
