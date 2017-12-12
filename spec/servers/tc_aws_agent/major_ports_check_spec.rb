require 'spec_helper'

opt = $server_config

##

panels_host_name = $gex_env == 'prod' ? 'srv3' : 'srv1'
sensu_host_name = $gex_env == 'prod' ? 'srv4' : 'srv1'
##
PANELS_IP = $gexcloud_servers[panels_host_name]['public_ip']
SENSU_IP = $gexcloud_servers[sensu_host_name]['public_ip']

describe 'Check closed ports' do
  describe host(PANELS_IP) do
    it "redis port 6379 closed" do should_not be_reachable.with( :port => 6379 ) end
    it "mysql port 3306 closed" do should_not be_reachable.with( :port => 3306 ) end
    it "es port 9200 closed" do should_not be_reachable.with( :port => 9200 ) end
    it "es port 9300 closed" do should_not be_reachable.with( :port => 9300 ) end
  end
end

describe "Connect to adminpanels #{panels_host_name} on ports 8081, 8082" do
  describe host(PANELS_IP) do
    it "ping" do should be_reachable end
    # it "port 8081 check" do should_not be_reachable.with( :port => 8081 ) end
    # it "port 8081 check" do should_not be_reachable.with( :port => 8082 ) end
  end
end

describe 'Check port 80 - socks_proxy_ip' do
  describe host('172.82.184.108') do
    it { should be_reachable.with( :port => 80 ) }
  end
end


describe 'Check port 15672 on rabbit.galacticexchange.io' do
  describe host('rabbit.galacticexchange.io') do
    it { should be_reachable.with( :port => 15672 ) }
  end
end


describe 'Check port 80 on api.galacticexchange.io' do
  describe host('api.galacticexchange.io') do
    it { should be_reachable.with( :port => 80 ) }
  end
end

describe 'Check port 5672 on rabbit' do
  describe host('104.247.194.116') do
    it { should be_reachable.with( :port => 5672 ) }
  end
end

describe 'Check port 15672 on rabbit' do
  describe host('104.247.194.116') do
    it { should be_reachable.with( :port => 15672 ) }
  end
end



# describe "free memory > 500 mB" do
#   it "check" do
#     freemem = host_inventory['memory']['free'].delete("kB").to_i
#     freespace = host_inventory['filesystem']['/dev/sda2']['kb_available'].delete("kB").to_i
#
#     puts "free space:"
#     puts host_inventory['filesystem']['/dev/sda2']['kb_available']
#     puts "free memory:"
#     puts freemem
#     expect(freemem).to be > 512000
#   end
# end
