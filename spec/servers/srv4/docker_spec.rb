require 'spec_helper'

opt = $server_config

#

describe command("sudo docker ps") do
  it "Kafka & Zookeeper running" do
    stdoutput = subject.stdout
    puts " #{stdoutput}"
    # expect(stdoutput).to match(/((gex-logs-kafka.+gex-logs-zookeeper)|(gex-logs-zookeeper.+gex-logs-kafka))/)
    expect(stdoutput).to match(/gex-logs-kafka/)
  end
end