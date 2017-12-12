require 'spec_helper'

opt = $server_config

##
API_IP = '104.247.194.115'

describe 'connect to api on prod' do
  describe host(API_IP) do
    # ping
    it { should be_reachable }
    # tcp port 8000
    it { should be_reachable.with( :port => 8000 ) }
  end
end

# describe command("") do
#   it "version" do
#     expect(subject.stdout).to match(/^3\./)
#   end
# endping api
