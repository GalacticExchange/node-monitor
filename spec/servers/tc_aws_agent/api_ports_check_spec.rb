require 'spec_helper'

opt = $server_config

##
API_IP = '104.247.194.115'

describe 'Сonnect to api on port 80' do
  describe host(API_IP) do
    it { should be_reachable.with( :port => 80 ) }
  end
end

