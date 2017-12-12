require 'spec_helper'

opt = $server_config
dc = "docker exec gex-provisioner"

if $gex_env == 'prod'
  ROUTE_IP = "51.1.0.52"
else
  ROUTE_IP = "51.1.0.50"
end



describe 'api network tests' do
  # ping hosts
  target_hosts = ["openvpn", "proxy", "webproxy", "master.gex", "provisioner","git.gex"]
  di_ping_all("gex-provisioner", target_hosts)


  describe command("#{dc} ip route") do
    it "ip route" do
      #expect(subject.stdout).to match(/#{ROUTE_IP} dev eth0  scope link  src 51.0.0.55 /)
    end
  end

  describe command("#{dc} ls /data/scripts") do
    it "dir is not empty" do
      expect(subject.stdout).to match(/.+/)
    end
  end

  describe command("#{dc} ruby -v") do
    it "dir is not empty" do
      expect(subject.stdout).to match(/2\.3\.3/)
    end
  end

end

if $gex_env == 'main'
  describe command("#{dc} pgrep -f sidekiq | wc -l") do
    it "response" do
      expect(subject.stdout.to_i).to eq(1)
    end
  end

  describe command("#{dc} pgrep -f run_gush | wc -l") do
    it "response" do
      expect(subject.stdout.to_i).to eq(1)
    end
  end


end