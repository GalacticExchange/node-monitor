require 'spec_helper'

opt = $server_config
LOGS_KAFKA_PRIVAT_IP = $gex_env == 'prod' ? "51.0.0.62" : "51.0.0.62"

HOSTNAME = "gex-api"
DC = "docker exec #{HOSTNAME}"
##

describe 'api network tests' do
  target_hosts = ["rabbit", "logs-elasticsearch", "stats-kafka", "sensu", "redis", "mysql", "elasticsearch", "8.8.8.8", "git.gex"]
  di_ping_all("gex-api", target_hosts)

  di_port_is_listening(HOSTNAME, 80)

  describe command("#{DC} ip -4 a show eth1") do
    it "ip route" do
      expect(subject.stdout).to match(/inet 51.0.0.21/)
    end
  end


  describe command("#{DC} ls /mount/ansible") do
    it "dir is not empty" do
      expect(subject.stdout).to match(/.+/)
    end
  end


  describe command("#{DC} ls /mount/ansibledata") do
    it "dir is not empty" do
      expect(subject.stdout).to match(/.+/)
    end
  end


  di_port_check("gex-api", LOGS_KAFKA_PRIVAT_IP, "9092", "logs-kafka")
  di_port_check("gex-api", "logs-elasticsearch", "9200")

end


