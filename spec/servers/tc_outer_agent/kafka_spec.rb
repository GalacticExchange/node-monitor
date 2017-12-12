require 'spec_helper'

opt = $server_config

##

describe 'ping log.devgex.net and check port 9092' do
  describe host('log.devgex.net') do
    it { should be_reachable }
    it { should be_reachable.with( :port => 9092 ) }
  end
end
