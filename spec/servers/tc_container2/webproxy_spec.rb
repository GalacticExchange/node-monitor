require 'spec_helper'

opt = $server_config
IP_ADDR = $gex_env == 'prod' ? "104.247.194.117/29" : "46\.172\.71\.57\/24"
IP_ROUTE_DFLT = $gex_env == 'prod' ? "104\.247\.194\.113" : "46\.172\.71\.33"
IP_ROUTE_3 = $gex_env == 'prod' ? "104.247.194.112/29" : "46\.172\.71\.0\/24"
HOSTNAME = "gex-webproxy"

# describe command("hostname") do
#   it "hostname" do
#     expect(subject.stdout).to match(/api/)
#   end
# end

##
describe 'webproxy network' do

  di_port_is_listening(HOSTNAME, 80)

  describe command("docker exec #{HOSTNAME} ip -4 a") do
    it "#{HOSTNAME} ip addr" do
      expect(subject.stdout).to match(/inet #{IP_ADDR}/)
      expect(subject.stdout).to match(/inet 51\.0\.0\.32\/9/)
    end
  end

  describe command("docker exec #{HOSTNAME} ip route") do
    it "#{HOSTNAME} ip route" do
      expect(subject.stdout).to match(/default via #{IP_ROUTE_DFLT}/)
      expect(subject.stdout).to match(/#{IP_ROUTE_3}/)
      expect(subject.stdout).to match(/51\.0\.0\.0\/9/)
      expect(subject.stdout).to match(/51\.128\.0\.0\/16/)
    end
  end

end

di_process_running(HOSTNAME, "nginx")
