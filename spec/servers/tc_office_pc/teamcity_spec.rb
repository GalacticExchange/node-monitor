require 'spec_helper'
#require 'serverspec_extended_types'

opt = $server_config

##
GEX4_IP = '104.247.203.210'
AWS_IP = '52.34.87.158'

# describe 'connect to teamcity server on PROD' do
#   describe host(GEX4_IP) do
#     it { should be_reachable.with( :port => 8111 ) }
#   end
# end

# describe http_get(8111, '104.247.203.210', 'http://104.247.203.210') do
#   its(:status) { should eq 200 }
# end

describe 'connect to teamcity server on AWS' do
  describe host(AWS_IP) do
    it { should be_reachable.with( :port => 8111 ) }
  end
end