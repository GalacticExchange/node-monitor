require 'spec_helper'
require 'aws-sdk'


opt = $server_config
require 'spec_helper'

##
API_IP = '46.172.71.54'
IPs = ['46.172.71.53', '46.172.71.54', '46.172.71.59']

describe '-Monitoring nodes-' do
  IPs.each {|e|
    describe host(e) do
      it "is reachable by Ping" do should be_reachable end
    end
  }
  # describe host(API_IP) do
  #   it "is reachable by Ping" do should be_reachable end
  # end
end