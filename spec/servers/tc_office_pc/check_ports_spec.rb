require 'spec_helper'

opt = $server_config
puts "opt = #{opt}"
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



# describe "Connect to adminpanels #{panels_host_name} on ports 8081, 8082" do
#   describe host(PANELS_IP) do
#     it "ping" do should be_reachable end
#     # if $gex_env == 'prod'
#     #   it "closed port 8081 check" do should be_reachable.with( :port => 8081 ) end
#     #   it "closed port 8082 check" do should be_reachable.with( :port => 8082 ) end
#     # else
#       it "closed port 8081 check" do should_not be_reachable.with( :port => 8081 ) end
#       it "closed port 8082 check" do should_not be_reachable.with( :port => 8082 ) end
#
#     # end
#   end
# end


if $gex_env == 'prod'
  describe "Connect to adminpanels #{panels_host_name} on ports 8081, 8082" do
    describe host(PANELS_IP) do
      it "ping" do should be_reachable end
      it "closed port 8081 check" do should be_reachable.with( :port => 8081 ) end
      it "closed port 8082 check" do should be_reachable.with( :port => 8082 ) end
    end
  end
else
  describe "Connect to adminpanels #{panels_host_name} on ports 8081, 8082" do
    describe host(PANELS_IP) do
      it "ping" do should be_reachable end
      it "closed port 8081 check" do should_not be_reachable.with( :port => 8081 ) end
      it "closed port 8082 check" do should_not be_reachable.with( :port => 8082 ) end
    end
  end
end


describe "Connect to sensu #{sensu_host_name} on port 3010" do
  describe host(SENSU_IP) do
    it "ping" do should be_reachable end
    it "port 3010 check" do should be_reachable.with( :port => 3010 ) end
  end
end


# describe command("curl http://webproxy.devgex.net") do
#   it "response" do
#     expect(subject.stdout).to match(/<html[^>]*>.*?Welcome to the Galactic Exchange Docs/im)
#   end
# end