require 'spec_helper'

opt = $server_config

##

describe 'Connect to' do
  describe host('api.galacticexchange.io') do
    it "Ping" do
      should be_reachable
    end
    it "Port 80 check" do
      should be_reachable.with( :port => 80 )
    end
  end
end

describe 'Connect to' do
  describe host('hub.galacticexchange.io') do
    it "Ping" do
      should be_reachable
    end
    it "Port 80 check" do
      should be_reachable.with( :port => 80 )
    end
  end
end