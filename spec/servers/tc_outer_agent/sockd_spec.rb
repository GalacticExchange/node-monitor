require 'spec_helper'

opt = $server_config

##

describe 'Check port 80 - socks_proxy_ip' do
  describe host('46.172.71.55') do
    it { should be_reachable.with( :port => 80 ) }
  end
end
