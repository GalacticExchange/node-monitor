require 'spec_helper'
require 'aws-sdk'


opt = $server_config
require 'spec_helper'

##
API_IP = '46.172.71.54'
IPs = ['46.172.71.53', '46.172.71.54', '35.164.247.179', '8.8.8.8']

describe 'Pinging nodes' do
  IPs.each {|e|
    describe host(e) do
      it { should be_reachable }
    end
  }
  # describe host(API_IP) do
  #   it "is reachable by Ping" do should be_reachable end
  # end
end