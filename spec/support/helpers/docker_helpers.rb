module DockerHelpers

  require "rspec/expectations"

  def di_process_is_running(base_host, process)
    describe command("docker exec #{base_host} pgrep -f #{process} ") do
      it "Process #{process} is running" do
        expect(subject.exit_status).to eq(0)
      end
    end
  end


  def di_ping(base_host, target_host, target_hostname = target_host)
    describe "Ping #{target_hostname}" do
      describe command("docker exec #{base_host} ping #{target_host} -c2 -w2") do
        it "Ping #{target_hostname} from host #{base_host}" do
          expect(subject.exit_status).to eq(0)
        end
      end
    end
  end


  def di_ping_all(base_host, target_host_arr)
    target_host_arr.each do |target_host|
      di_ping(base_host, target_host)
    end
  end


  def di_port_check_only(base_host, target_host, target_port, target_hostname = target_host, ping = true)
    is_failed = false
    describe command("docker exec #{base_host} nc -vz #{target_host} #{target_port}") do
      it "Check port #{target_port} on #{target_hostname} from host #{base_host}" do
        expect(subject.exit_status).to eq(0)
      end
    end
  end


  def di_port_check(base_host, target_host, target_port, target_hostname = target_host, ping = true)
    is_port_check_failed = false
    cmd_text = "docker exec #{base_host} nc -vz #{target_host} #{target_port}"
    cmd = command(cmd_text)
    is_port_check_failed = true if cmd.exit_status != 0
    # puts "failed = #{is_port_check_failed}"

    describe cmd_text do
      it "Check port #{target_port} on #{target_hostname} from host #{base_host}" do
        expect(is_port_check_failed).to eq(false)
      end
    end

    if is_port_check_failed
      di_ping(base_host, target_host, target_hostname)
    end

  end


  def di_port_is_listening (base_host, port)
    describe command("docker exec #{base_host} ss -ltn|grep :#{port}") do
      it "Port #{port} on #{base_host} is listening" do
        expect(subject.stdout).to match(/LISTEN.+:#{port}/)
      end
    end

  end


  def di_process_running(base_host, process_name)
    describe command("docker exec #{base_host}   pgrep -f #{process_name} ") do
      it "#{process_name} is running on #{base_host}" do
        expect(subject.exit_status).to eq(0)
      end
    end
  end


end
