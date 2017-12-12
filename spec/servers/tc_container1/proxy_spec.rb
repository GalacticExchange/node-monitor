require 'spec_helper'

opt = $server_config
HOSTNAME = "proxy"

##
#describe 'hacked connections' do
  describe command("docker exec proxy ss | grep smtp") do
    it "not hacked - no outgoing smtp" do
      expect(subject.stdout).not_to match(/tcp/)
      expect(subject.stdout).not_to match(/\:smtp/)
    end
  end
#end

describe command("docker exec #{HOSTNAME} ip route") do
  it "#{HOSTNAME} ip route" do
    expect(subject.stdout).to match(/51\.0\.0\.0\/9/)
    expect(subject.stdout).to match(/51\.128\.0\.0\/16/)
  end
end