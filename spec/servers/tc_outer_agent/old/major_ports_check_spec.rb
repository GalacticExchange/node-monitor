require 'spec_helper'

opt = $server_config

##

describe 'Check port 80 on PROXY - 172.82.184.108' do
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
    it { should be_reachable.with( :port => 15672, :proto => 'http' ) }
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
