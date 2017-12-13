require 'spec_helper'
require 'aws-sdk'

opt = $server_config
require 'spec_helper'

##
API_IP = '46.172.71.54'

describe 'Сonnect to api on port 80' do
  describe host(API_IP) do
    it "Ping" do should be_reachable end
  end
end