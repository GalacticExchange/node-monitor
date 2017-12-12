require 'spec_helper'
require 'serverspec_extended_types'

opt = $server_config

##

describe http_get(80, 'docs.galacticexchange.io', 'http://docs.galacticexchange.io') do
  its(:status) { should eq 200 }
end

# describe http_get(80, 'docs.galacticexchange.io', 'http://docs.galacticexchange.io') do
#   its(:body) { should match /<html>/ }
# end

describe command("curl http://docs.galacticexchange.io") do
  it "response" do
    expect(subject.stdout).to match(/<html[^>]*>.*?Getting Started/im)
  end
end

