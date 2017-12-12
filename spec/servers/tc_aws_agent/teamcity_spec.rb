require 'spec_helper'

opt = $server_config

##
GEX4_IP = '104.247.203.210'
OUTER_IP = '52.34.87.158'

# describe 'connect to teamcity server on PROD' do
#   describe host(GEX4_IP) do
#     it { should be_reachable.with( :port => 8111 ) }
#   end
# end






# describe http_get(8111, '104.247.203.210', 'http://104.247.203.210') do
#   its(:status) { should eq 200 }
# end

# describe command("curl http://104.247.203.210:8111") do
#   it "response" do
#     expect(subject.stdout).to match(/<html[^>]*>.*?TeamCity|Authentication required/im)
#   end
# end


# describe 'connect to teamcity server on AWS' do
#   describe host(OUTER_IP) do
#     it { should be_reachable.with( :port => 8111 ) }
#   end
# end

