require 'spec_helper'

opt = $server_config

LOGS_KAFKA_PUBLIC_IP = $gex_env == 'prod' ? "104.247.203.211" : "log.devgex.net" #"46.172.71.53"

describe 'ping logs-kafka and check port 9092' do
  describe host(LOGS_KAFKA_PUBLIC_IP) do
    it { should be_reachable }
    it { should be_reachable.with( :port => 9092 ) }
  end
end

