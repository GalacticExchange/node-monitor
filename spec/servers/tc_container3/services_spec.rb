require 'spec_helper'

opt = $server_config

##

describe command("docker ps") do
  it "gexlogs-fluentd-kafka-elastic running" do
    expect(subject.stdout).to match(/gex-logs-fluentd-kafka-elastic/)
  end
  it "gex-logs-fluentd-mysql-multi running" do
    expect(subject.stdout).to match(/gex-logs-fluentd-mysql-multi/)
  end
  it "gex-logs-fluentd-multi running" do
    expect(subject.stdout).to match(/gex-logs-fluentd-multi/)
  end
end



# sensu-rabbit - only for MAIN check routes with +++
# root@sensu-rabbit:/# ip route
# default via 172.17.0.1 dev eth0 +++
# 51.0.0.0/9 dev eth1 proto kernel scope link src 51.0.0.23 +++
# 51.128.0.0/16 via 51.0.1.8 dev eth1
# 172.17.0.0/16 dev eth0 proto kernel scope link src 172.17.0.34


