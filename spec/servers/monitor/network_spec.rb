require 'spec_helper'
require 'aws-sdk'

opt = $server_config
require 'spec_helper'

##
API_IP = '10.1.0.21'

describe 'Сonnect to api on port 80' do
  describe host(API_IP) do
    it "Ping" do should be_reachable end
  end
end