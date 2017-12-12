require 'spec_helper'

opt = $server_config

# debug
# describe command("wget -P /tmp http://51.0.1.6/boxes/cdh-version.txt") do
#   its(:exit_status) { should eq 0 }
# end
#
# describe file('/tmp/cdh-version.txt') do
#   its(:content) { should match /version=/ }
# end




#
describe command("curl http://dxiolmvesnizm.cloudfront.net/cdh-version.txt") do
  it "cdh version" do
    expect(subject.stdout).to match(/version=/im)
  end
end

apps = ["data_enchilada" , "ubuntu16", "zoomdata", "rocana", "datameer"]
apps.each do |app|
  describe command("curl http://s3-us-west-2.amazonaws.com/gex-apps/#{app}-version.txt") do
    it "response" do
      expect(subject.stdout).to match(/version=/im)
    end
  end


end