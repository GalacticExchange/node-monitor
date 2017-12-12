require 'spec_helper'

opt = $server_config

##
di_ping("gex-sensu", "stats-kafka")
di_port_check("gex-sensu", "sensu-redis", "6379")


if $gex_env =="main" then
  describe command("docker exec gex-sensu-rabbit ip route") do
    it "gex-sensu-rabbit ip route" do
      expect(subject.stdout).to match(/default\ via\ 172\.17\.0\.1\ dev\ eth0/)
      expect(subject.stdout).to match(/51\.0\.0\.0\/9\ dev\ eth1\ +proto\ kernel\ +scope\ link\ +src/) #\ 51\.0\.0\.23/)
      expect(subject.stdout).to match(/51\.128\.0\.0\/16\ +via 51.0.1.8 dev eth1/)
      expect(subject.stdout).to match(/172\.17\.0\.0\/16\ dev\ eth0\ +proto\ kernel\ +scope\ link\ +src/) #\ 172\.17\.0\.34/)
    end
  end

end



# sensu-rabbit - only for MAIN check routes with +++
# root@sensu-rabbit:/# ip route
# default via 172.17.0.1 dev eth0 +++
# 51.0.0.0/9 dev eth1 proto kernel scope link src 51.0.0.23 +++
# 51.128.0.0/16 via 51.0.1.8 dev eth1
# 172.17.0.0/16 dev eth0 proto kernel scope link src 172.17.0.34


