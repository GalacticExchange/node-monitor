require 'spec_helper'

opt = $server_config

##

describe 'ping api.galacticexchange.io' do
  describe host('api.galacticexchange.io') do
    # ping
    it { should be_reachable }
    it { should be_reachable.with( :port => 80 ) }

  end
end

describe 'ping hub.galacticexchange.io' do
  describe host('hub.galacticexchange.io') do
    # ping
    it { should be_reachable }
    it { should be_reachable.with( :port => 80 ) }
  end
end